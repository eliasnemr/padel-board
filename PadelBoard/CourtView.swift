import SwiftUI

/// The court drawn to scale, with draggable players and ball.
struct CourtView: View {
    let court: CourtType
    let spots: Step
    let previous: Step?
    /// Points per metre.
    let metre: CGFloat
    let hop: Int
    let locked: Bool
    @Binding var dragging: Piece?
    var onMove: (Piece, Spot) -> Void
    var onDrop: () -> Void

    private var size: CGSize {
        CGSize(width: court.widthMetres * metre, height: CourtType.lengthMetres * metre)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            CourtSurface()
            if let previous {
                MovementTrails(from: previous, to: spots, size: size)
            }
            if let ball = spots[.ball] {
                BallToken(hop: hop, lifted: dragging == .ball)
                    .position(point(ball))
                    .gesture(drag(.ball))
                    .accessibilityLabel(Piece.ball.accessibilityName)
                    .zIndex(3)
            }
            ForEach(Piece.allCases.filter { $0.isPlayer && spots[$0] != nil }) { piece in
                PlayerToken(piece: piece, lifted: dragging == piece)
                    .position(point(spots[piece]!))
                    .gesture(drag(piece))
                    .zIndex(dragging == piece ? 4 : 2)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: size.width, height: size.height)
        .coordinateSpace(.named("court"))
        .onChange(of: held) { _, new in
            withAnimation(.spring(duration: 0.3, bounce: 0.45)) { dragging = new }
        }
    }

    private func point(_ spot: Spot) -> CGPoint {
        CGPoint(x: spot.x * size.width, y: spot.y * size.height)
    }

    /// `held` resets by itself when the system cancels a touch, so a token never stays lifted.
    @GestureState private var held: Piece?

    private func drag(_ piece: Piece) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("court"))
            .updating($held) { _, state, _ in
                if !locked { state = piece }
            }
            .onChanged { value in
                guard !locked else { return }
                onMove(piece, Spot(x: value.location.x / size.width, y: value.location.y / size.height))
            }
            .onEnded { _ in
                if !locked { onDrop() }
            }
    }
}

// MARK: - Court surface

/// Blue turf, white service lines, the net across the middle and a glass wall around it.
private struct CourtSurface: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Service lines sit 6.95 m from the net, 3.05 m from each back wall.
            let service = 3.05 / CourtType.lengthMetres
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.court)
                    .overlay(RoundedRectangle(cornerRadius: 6).inset(by: -2.5).stroke(Theme.glass, lineWidth: 5))
                    .shadow(color: Color(red: 0.16, green: 0.12, blue: 0.09).opacity(0.12), radius: 16, y: 12)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h * service))
                    path.addLine(to: CGPoint(x: w, y: h * service))
                    path.move(to: CGPoint(x: 0, y: h * (1 - service)))
                    path.addLine(to: CGPoint(x: w, y: h * (1 - service)))
                    path.move(to: CGPoint(x: w / 2, y: h * service))
                    path.addLine(to: CGPoint(x: w / 2, y: h * (1 - service)))
                }
                .stroke(.white.opacity(0.9), lineWidth: 2)
                Capsule()
                    .fill(Theme.text)
                    .frame(width: w + 20, height: 4)
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                    .position(x: w / 2, y: h / 2)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Tokens

private struct PlayerToken: View {
    let piece: Piece
    let lifted: Bool

    var body: some View {
        Text(piece.number)
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Circle().fill(piece.isYourTeam ? Theme.yourTeam : Theme.opponents))
            .overlay(Circle().strokeBorder(.white, lineWidth: 3))
            .shadow(color: .black.opacity(lifted ? 0.4 : 0.3), radius: lifted ? 12 : 4, y: lifted ? 10 : 3)
            .scaleEffect(lifted ? 1.18 : 1)
            .frame(width: 48, height: 48)
            .contentShape(Circle())
            .accessibilityElement()
            .accessibilityLabel(piece.accessibilityName)
            .accessibilityHint("Drag to move")
    }
}

/// The ball swells as it flies between steps, as if seen from above.
private struct BallToken: View {
    let hop: Int
    let lifted: Bool

    var body: some View {
        ZStack {
            Ellipse()
                .fill(.black.opacity(0.3))
                .frame(width: 12, height: 6)
                .offset(y: 8)
            Circle()
                .fill(Theme.ball)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(.white, lineWidth: 2))
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                .keyframeAnimator(initialValue: 1.0, trigger: hop) { content, scale in
                    content
                        .scaleEffect(scale)
                        .offset(y: -(scale - 1) * 7)
                } keyframes: { _ in
                    CubicKeyframe(1.9, duration: 0.36)
                    CubicKeyframe(1.0, duration: 0.44)
                }
                .scaleEffect(lifted ? 1.3 : 1)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
    }
}

// MARK: - Movement arrows

/// A faded ring where each player stood in the previous step, and a dashed arrow to where they are now.
private struct MovementTrails: View {
    let from: Step
    let to: Step
    let size: CGSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashPhase: CGFloat = 0

    private struct Trail: Identifiable {
        let id: Piece
        let start: CGPoint
        let end: CGPoint
        let yourTeam: Bool
    }

    private var trails: [Trail] {
        Piece.allCases.compactMap { piece in
            guard piece.isPlayer, let a = from[piece], let b = to[piece], a.distance(to: b) > 0.03 else { return nil }
            return Trail(
                id: piece,
                start: CGPoint(x: a.x * size.width, y: a.y * size.height),
                end: CGPoint(x: b.x * size.width, y: b.y * size.height),
                yourTeam: piece.isYourTeam
            )
        }
    }

    var body: some View {
        ZStack {
            ForEach(trails) { trail in
                let colour = trail.yourTeam ? Theme.roseLight : Color.white.opacity(0.85)
                Circle()
                    .fill(trail.yourTeam ? Theme.rose.opacity(0.25) : .white.opacity(0.15))
                    .overlay(Circle().stroke(colour, style: StrokeStyle(lineWidth: 2, dash: [3, 3])))
                    .frame(width: 28, height: 28)
                    .position(trail.start)
                ArrowLine(start: trail.start, end: trail.end)
                    .stroke(colour, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round, dash: [6, 6], dashPhase: dashPhase))
                ArrowHead(start: trail.start, end: trail.end)
                    .fill(colour)
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .transition(.opacity)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) { dashPhase = -12 }
        }
    }
}

/// Stops short of the player token so the arrowhead stays visible.
private func arrowTip(start: CGPoint, end: CGPoint) -> (tip: CGPoint, unit: CGVector)? {
    let dx = end.x - start.x
    let dy = end.y - start.y
    let length = (dx * dx + dy * dy).squareRoot()
    guard length > 34 else { return nil }
    let unit = CGVector(dx: dx / length, dy: dy / length)
    return (CGPoint(x: end.x - unit.dx * 26, y: end.y - unit.dy * 26), unit)
}

private struct ArrowLine: Shape {
    let start: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let tip = arrowTip(start: start, end: end)?.tip else { return path }
        path.move(to: start)
        path.addLine(to: tip)
        return path
    }
}

private struct ArrowHead: Shape {
    let start: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let (tip, unit) = arrowTip(start: start, end: end) else { return path }
        let back = CGPoint(x: tip.x - unit.dx * 9, y: tip.y - unit.dy * 9)
        let normal = CGVector(dx: -unit.dy, dy: unit.dx)
        path.move(to: CGPoint(x: tip.x + unit.dx * 3, y: tip.y + unit.dy * 3))
        path.addLine(to: CGPoint(x: back.x + normal.dx * 5, y: back.y + normal.dy * 5))
        path.addLine(to: CGPoint(x: back.x - normal.dx * 5, y: back.y - normal.dy * 5))
        path.closeSubpath()
        return path
    }
}
