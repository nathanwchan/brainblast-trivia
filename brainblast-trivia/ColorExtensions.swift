import SwiftUI

extension Color {
    static let rainbowGradient = LinearGradient(
        gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let subtleRainbowGradient = LinearGradient(
        gradient: Gradient(colors: [
            .red.opacity(0.8),
            .orange.opacity(0.8),
            .yellow.opacity(0.8),
            .green.opacity(0.8),
            .blue.opacity(0.8),
            .purple.opacity(0.8)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
