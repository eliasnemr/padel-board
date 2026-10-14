import Foundation
import Observation

/// The board's state: which court is showing, which step, and where everything stands.
/// Saved on the device so a play is still there after the app closes.
@Observable
final class BoardStore {
    var court: CourtType = .doubles { didSet { save() } }
    var step = 0
    private(set) var plans: [CourtType: [Step]]

    private static let saveKey = "board.v1"

    private struct Saved: Codable {
        var court: CourtType
        var plans: [CourtType: [Step]]
    }

    /// Debug builds only, for App Store screenshots: `-fresh` starts from the default play
    /// without reading or writing the save, `-court singles` and `-step 2` pick what shows.
    private let savesEnabled: Bool

    init() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        func value(after flag: String) -> String? {
            guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        if args.contains("-fresh") {
            savesEnabled = false
            plans = Dictionary(uniqueKeysWithValues: CourtType.allCases.map { ($0, Plays.start(for: $0)) })
            court = value(after: "-court").flatMap(CourtType.init(rawValue:)) ?? .doubles
            if let step = value(after: "-step").flatMap(Int.init), (1...Plays.stepCount).contains(step) {
                self.step = step - 1
            }
            return
        }
        #endif
        savesEnabled = true
        if let data = UserDefaults.standard.data(forKey: Self.saveKey),
           let saved = try? JSONDecoder().decode(Saved.self, from: data),
           CourtType.allCases.allSatisfy({ saved.plans[$0]?.count == Plays.stepCount }) {
            plans = saved.plans
            court = saved.court
        } else {
            plans = Dictionary(uniqueKeysWithValues: CourtType.allCases.map { ($0, Plays.start(for: $0)) })
        }
    }

    var spots: Step { plans[court]?[step] ?? [:] }

    /// Where everything stood in the step before this one, for the movement arrows.
    var previousSpots: Step? {
        guard step > 0 else { return nil }
        return plans[court]?[step - 1]
    }

    func move(_ piece: Piece, to spot: Spot) {
        plans[court]?[step][piece] = spot.clamped()
    }

    func resetStep() {
        plans[court]?[step] = Plays.start(for: court)[step]
        save()
    }

    func save() {
        guard savesEnabled, let data = try? JSONEncoder().encode(Saved(court: court, plans: plans)) else { return }
        UserDefaults.standard.set(data, forKey: Self.saveKey)
    }
}
