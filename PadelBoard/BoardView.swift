import SwiftUI

/// The only screen: pick a court, drag players and the ball, and step through the play.
struct BoardView: View {
    @State private var store = BoardStore()
    @State private var playing = false
    @State private var playTask: Task<Void, Never>?
    @State private var dragging: Piece?
    @State private var hop = 0

    static let stepSeconds: Double = 1.8
    static let stepAnimation = Animation.spring(duration: 0.8, bounce: 0.35)

    var body: some View {
        VStack(spacing: 16) {
            header
            courtPicker
            GeometryReader { geo in
                let metre = min(geo.size.height / CGFloat(CourtType.lengthMetres), (geo.size.width - 24) / 10)
                CourtView(
                    court: store.court,
                    spots: store.spots,
                    previous: store.previousSpots,
                    metre: metre,
                    hop: hop,
                    locked: playing,
                    dragging: $dragging,
                    onMove: { store.move($0, to: $1) },
                    onDrop: { store.save() }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            stepControls
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Theme.background.ignoresSafeArea())
        .foregroundStyle(Theme.text)
        .sensoryFeedback(.selection, trigger: store.step)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: dragging) { _, new in new != nil }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Padel board")
                .font(.system(size: 26, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                stop()
                withAnimation(Self.stepAnimation) { store.resetStep() }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.surface).shadow(color: .black.opacity(0.06), radius: 4, y: 2))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset this step")
        }
    }

    // MARK: - Court picker

    private var courtPicker: some View {
        HStack(spacing: 4) {
            ForEach(CourtType.allCases) { court in
                let on = store.court == court
                Button {
                    stop()
                    withAnimation(.snappy(duration: 0.4)) { store.court = court }
                } label: {
                    Text(court.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(on ? Theme.text : Theme.muted)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            Capsule()
                                .fill(on ? Theme.surface : .clear)
                                .shadow(color: .black.opacity(on ? 0.1 : 0), radius: 4, y: 2)
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Capsule().fill(Theme.track))
    }

    // MARK: - Steps and play

    private var stepControls: some View {
        HStack(spacing: 8) {
            Button {
                playing ? stop() : play()
            } label: {
                Image(systemName: playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Theme.rose).shadow(color: Theme.rose.opacity(0.32), radius: 12, y: 6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(playing ? "Pause" : "Play all steps")

            ForEach(0..<Plays.stepCount, id: \.self) { index in
                stepButton(index)
            }
        }
    }

    private func stepButton(_ index: Int) -> some View {
        let on = store.step == index
        let filled = on || (playing && index < store.step)
        return Button {
            stop()
            go(to: index)
        } label: {
            Text("\(index + 1)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(on ? Theme.roseDark : Theme.text)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(RoundedRectangle(cornerRadius: 12).fill(on ? Theme.roseTint : Theme.surface))
                .overlay(alignment: .bottomLeading) {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Theme.rose)
                            .frame(width: filled ? geo.size.width : 0, height: 3)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .animation(playing && on ? .linear(duration: Self.stepSeconds) : .easeOut(duration: 0.2), value: filled)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(on ? Theme.rose : Theme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Step \(index + 1)")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func go(to index: Int) {
        guard index != store.step else { return }
        dragging = nil
        hop += 1
        withAnimation(Self.stepAnimation) { store.step = index }
    }

    private func play() {
        stop()
        playing = true
        playTask = Task { @MainActor in
            if store.step != 0 { go(to: 0) } else { hop += 1 }
            do {
                for index in 1..<Plays.stepCount {
                    try await Task.sleep(for: .seconds(Self.stepSeconds))
                    go(to: index)
                }
                try await Task.sleep(for: .seconds(Self.stepSeconds))
            } catch {
                return
            }
            playing = false
        }
    }

    private func stop() {
        playTask?.cancel()
        playTask = nil
        playing = false
    }
}

#Preview {
    BoardView()
}
