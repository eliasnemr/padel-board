import SwiftUI

@main
struct PadelBoardApp: App {
    var body: some Scene {
        WindowGroup {
            BoardView()
                // v1 is drawn for the light cream look only.
                .preferredColorScheme(.light)
        }
    }
}
