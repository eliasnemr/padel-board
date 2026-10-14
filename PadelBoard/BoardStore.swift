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

    init() {
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
        guard let data = try? JSONEncoder().encode(Saved(court: court, plans: plans)) else { return }
        UserDefaults.standard.set(data, forKey: Self.saveKey)
    }
}
