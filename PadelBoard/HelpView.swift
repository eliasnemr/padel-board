import SwiftUI

/// "How to use": what each control does, and a few ways to use the board with a partner or players.
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to use")
                        .font(.system(size: 30, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    Text("Show your game plan instead of explaining it with your hands.")
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.muted)
                }

                VStack(alignment: .leading, spacing: 20) {
                    HelpRow(symbol: "rectangle.split.1x2", title: "Pick a court") {
                        Text("Switch between **Doubles** and **Singles** at the top. Each court keeps its own plan.")
                    }
                    HelpRow(symbol: "hand.draw", title: "Drag the players and ball") {
                        Text("**1** and **2** are your team, **3** and **4** are the opponents. You can drag the ball too.")
                    }
                    HelpRow(symbol: "list.number", title: "Build the point in three steps") {
                        Text("Tap **1**, **2** or **3**, then move everyone to where they should be at that moment. Each step remembers its own positions.")
                    }
                    HelpRow(symbol: "arrow.up.forward", title: "Follow the arrows") {
                        Text("A faded ring shows where each player stood in the step before, and an arrow shows where they went.")
                    }
                    HelpRow(symbol: "play.fill", title: "Press play") {
                        Text("Watch the whole point move from step 1 to 3. Great for showing your partner before a match.")
                    }
                    HelpRow(symbol: "arrow.counterclockwise", title: "Start over") {
                        Text("The reset button puts the current step back to its starting positions.")
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ideas to try")
                        .font(.system(size: 20, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    IdeaRow("Serve and volley: where the server's partner waits, and when you both move up to the net.")
                    IdeaRow("Defending a lob: who goes back for it, and who covers the middle.")
                    IdeaRow("Return of serve: where to aim, and where the returner's partner stands.")
                    IdeaRow("Coaching: plan the drill before the session, then show it on court.")
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                dismiss()
            } label: {
                Text("Got it")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Capsule().fill(Theme.rose))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.background)
        }
        .background(Theme.background.ignoresSafeArea())
        .foregroundStyle(Theme.text)
    }
}

private struct HelpRow<Detail: View>: View {
    let symbol: String
    let title: String
    @ViewBuilder var detail: Detail

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.roseDark)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.roseTint))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                detail
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct IdeaRow: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle().fill(Theme.rose).frame(width: 6, height: 6).accessibilityHidden(true)
            Text(text)
                .font(.system(size: 15))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    HelpView()
}
