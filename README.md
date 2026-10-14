# Padel Board

A simple SwiftUI iPhone app for explaining a padel game plan: pick a doubles or singles court, drag the players and the ball, and step through the play.

- **Requirements:** Xcode 26, iOS 17+, iPhone
- **Run:** open `PadelBoard.xcodeproj`, pick your team under Signing & Capabilities, and run
- **Release:** listing text and review notes are in [`AppStore/`](AppStore/metadata.md); privacy and support pages are in [`docs/`](docs/)
- **What's next:** [ROADMAP.md](ROADMAP.md)

The design canvas: https://claude.ai/artifact/UBkkpiQKk4ynTtwuSVbxJ7

## How it's built

| File | What it holds |
|---|---|
| `Models.swift` | Court sizes, the pieces (four players and the ball), and the starting three-step play |
| `BoardStore.swift` | Current court and step, every position; saved to `UserDefaults` so a play survives a relaunch |
| `BoardView.swift` | The screen: header, court picker, play button and step buttons |
| `CourtView.swift` | The court drawn to scale (20 m long, 10 m or 6 m wide), dragging, ball hop, movement arrows |
| `Theme.swift` | Colours |

Positions are stored in unit coordinates (0–1 across and down the court), so switching court width keeps everyone in the same place relative to the lines.

Building from `~/Documents`: if code signing fails with "resource fork, Finder information, or similar detritus not allowed", build with a derived data folder outside `Documents` (Xcode's default is fine; only `-derivedDataPath build` inside the repo trips it).
