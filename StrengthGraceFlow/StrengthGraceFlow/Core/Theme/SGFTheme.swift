//
//  SGFTheme.swift
//  StrengthGraceFlow
//
//  Design system colors, typography, and spacing
//

import SwiftUI

// MARK: - Colors

extension Color {
    // Primary palette
    static let sgfPrimary = Color(hex: "8B5CF6")       // Soft purple
    static let sgfSecondary = Color(hex: "EC4899")     // Warm pink
    static let sgfAccent = Color(hex: "F59E0B")        // Golden amber

    // Background colors
    static let sgfBackground = Color(hex: "FFFBF7")    // Warm cream
    static let sgfSurface = Color.white
    static let sgfSurfaceSecondary = Color(hex: "F9FAFB")

    // Text colors
    static let sgfTextPrimary = Color(hex: "1F2937")   // Dark gray
    static let sgfTextSecondary = Color(hex: "6B7280") // Medium gray
    static let sgfTextTertiary = Color(hex: "9CA3AF")  // Light gray

    // Cycle phase colors
    static let sgfMenstrual = Color(hex: "EF4444")     // Soft red
    static let sgfFollicular = Color(hex: "10B981")    // Fresh green
    static let sgfOvulatory = Color(hex: "F59E0B")     // Warm amber
    static let sgfLuteal = Color(hex: "8B5CF6")        // Calming purple

    // Semantic colors
    static let sgfSuccess = Color(hex: "10B981")
    static let sgfWarning = Color(hex: "F59E0B")
    static let sgfError = Color(hex: "EF4444")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

extension Font {
    // Display fonts
    static let sgfLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let sgfTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let sgfTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let sgfTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body fonts
    static let sgfHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let sgfBody = Font.system(size: 17, weight: .regular, design: .default)
    static let sgfCallout = Font.system(size: 16, weight: .regular, design: .default)
    static let sgfSubheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let sgfFootnote = Font.system(size: 13, weight: .regular, design: .default)
    static let sgfCaption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing

struct SGFSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

struct SGFCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Button Styles

struct SGFPrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sgfHeadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(isDisabled ? Color.sgfTextTertiary : Color.sgfPrimary)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SGFSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sgfHeadline)
            .foregroundColor(.sgfPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(Color.sgfPrimary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Field Style

struct SGFTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.sgfBody)
            .padding(SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(Color.sgfSurfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(Color.sgfTextTertiary.opacity(0.3), lineWidth: 1)
            )
    }
}
