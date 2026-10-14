import Foundation

/// The two court sizes. Every padel court is 20 m long; only the width changes.
enum CourtType: String, CaseIterable, Codable, CodingKeyRepresentable, Identifiable {
    case doubles, singles

    var id: String { rawValue }
    var title: String { self == .doubles ? "Doubles" : "Singles" }
    var widthMetres: Double { self == .doubles ? 10 : 6 }
    static let lengthMetres: Double = 20
}

/// Everything you can drag on the court.
enum Piece: String, CaseIterable, Codable, CodingKeyRepresentable, Identifiable {
    case p1, p2, p3, p4, ball

    var id: String { rawValue }
    var isPlayer: Bool { self != .ball }
    var isYourTeam: Bool { self == .p1 || self == .p2 }

    var number: String {
        switch self {
        case .p1: "1"
        case .p2: "2"
        case .p3: "3"
        case .p4: "4"
        case .ball: ""
        }
    }

    var accessibilityName: String {
        switch self {
        case .p1: "Player 1, your team"
        case .p2: "Player 2, your team"
        case .p3: "Player 3, opponents"
        case .p4: "Player 4, opponents"
        case .ball: "Ball"
        }
    }
}

/// A position on the court in unit coordinates: x 0 → 1 left to right,
/// y 0 → 1 from the opponents' back wall to yours.
struct Spot: Codable, Equatable {
    var x: Double
    var y: Double

    func clamped() -> Spot {
        Spot(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
    }

    func distance(to other: Spot) -> Double {
        abs(x - other.x) + abs(y - other.y)
    }
}

/// Where every piece stands in one step of the play.
typealias Step = [Piece: Spot]

enum Plays {
    static let stepCount = 3

    /// The starting play for each court: serve, approach, own the net.
    static func start(for court: CourtType) -> [Step] {
        switch court {
        case .doubles:
            [
                [.p1: Spot(x: 0.72, y: 0.93), .p2: Spot(x: 0.30, y: 0.62), .p3: Spot(x: 0.26, y: 0.07), .p4: Spot(x: 0.72, y: 0.30), .ball: Spot(x: 0.66, y: 0.92)],
                [.p1: Spot(x: 0.68, y: 0.70), .p2: Spot(x: 0.32, y: 0.66), .p3: Spot(x: 0.30, y: 0.12), .p4: Spot(x: 0.72, y: 0.22), .ball: Spot(x: 0.44, y: 0.21)],
                [.p1: Spot(x: 0.66, y: 0.60), .p2: Spot(x: 0.34, y: 0.60), .p3: Spot(x: 0.30, y: 0.06), .p4: Spot(x: 0.70, y: 0.06), .ball: Spot(x: 0.50, y: 0.12)],
            ]
        case .singles:
            [
                [.p1: Spot(x: 0.66, y: 0.93), .p3: Spot(x: 0.34, y: 0.07), .ball: Spot(x: 0.62, y: 0.92)],
                [.p1: Spot(x: 0.50, y: 0.70), .p3: Spot(x: 0.42, y: 0.12), .ball: Spot(x: 0.62, y: 0.20)],
                [.p1: Spot(x: 0.50, y: 0.60), .p3: Spot(x: 0.50, y: 0.06), .ball: Spot(x: 0.70, y: 0.10)],
            ]
        }
    }
}
