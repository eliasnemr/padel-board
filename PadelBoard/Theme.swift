import SwiftUI

/// Colours from the design canvas: warm cream ground, rose for your team and actions,
/// dark brown for the opponents, a blue court.
enum Theme {
    static let background = Color(red: 0.962, green: 0.949, blue: 0.938)
    static let surface = Color.white
    static let track = Color(red: 0.944, green: 0.918, blue: 0.896)
    static let border = Color(red: 0.880, green: 0.848, blue: 0.820)
    static let text = Color(red: 0.240, green: 0.193, blue: 0.160)
    static let muted = Color(red: 0.504, green: 0.441, blue: 0.396)

    static let rose = Color(red: 0.912, green: 0.288, blue: 0.413)
    static let roseDark = Color(red: 0.722, green: 0.158, blue: 0.271)
    static let roseLight = Color(red: 0.952, green: 0.608, blue: 0.677)
    static let roseTint = Color(red: 0.991, green: 0.929, blue: 0.941)

    static let court = Color(red: 0.184, green: 0.373, blue: 0.525)
    static let glass = Color(red: 0.775, green: 0.835, blue: 0.865)
    static let ball = Color(red: 0.866, green: 0.937, blue: 0.223)

    static let yourTeam = rose
    static let opponents = text
}
