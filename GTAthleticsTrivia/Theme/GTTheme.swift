import SwiftUI

// MARK: - Georgia Tech Official Colors & Theme
struct GTTheme {
    // Primary Colors
    static let techGold = Color(red: 179/255, green: 163/255, blue: 105/255)   // #B3A369
    static let navyBlue = Color(red: 0/255, green: 48/255, blue: 87/255)       // #003057
    static let white = Color.white

    // Secondary Colors
    static let darkGold = Color(red: 158/255, green: 143/255, blue: 83/255)
    static let lightGold = Color(red: 228/255, green: 223/255, blue: 205/255)  // #E4DFCD
    static let lightBlue = Color(red: 0/255, green: 79/255, blue: 142/255)

    // Functional
    static let background = Color(red: 15/255, green: 15/255, blue: 20/255)
    static let cardBackground = Color(red: 25/255, green: 30/255, blue: 45/255)
    static let success = Color(red: 76/255, green: 175/255, blue: 80/255)
    static let error = Color(red: 211/255, green: 47/255, blue: 47/255)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
}

// MARK: - GT Button Style
struct GTButtonStyle: ButtonStyle {
    var isSecondary: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isSecondary ? GTTheme.techGold : GTTheme.navyBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSecondary ? GTTheme.navyBlue : GTTheme.techGold)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSecondary ? GTTheme.techGold : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - GT Card Modifier
struct GTCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(GTTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(GTTheme.techGold.opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    func gtCard() -> some View {
        modifier(GTCardModifier())
    }
}
