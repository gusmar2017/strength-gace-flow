//
//  SGFTheme.swift
//  StrengthGraceFlow
//
//  Design system colors, typography, and spacing
//

import SwiftUI

// MARK: - Colors
// Based on Strength Grace Flow Design System v1.0
// See: docs/design_system/design-system.md

extension Color {
    // MARK: - Core Palette
    static let sgfPrimary = Color(hex: "B35C44")       // Deep Terracotta - primary accents, buttons, active states
    static let sgfSecondary = Color(hex: "6F8F9B")     // Dusty Blue - secondary accents, calm elements
    static let sgfAccent = Color(hex: "D8B8A6")        // Soft Clay Neutral - tertiary accents, highlights

    // MARK: - Background Colors
    static let sgfBackground = Color(hex: "F6F1EA")    // Soft Sand - backgrounds, cards
    static let sgfSurface = Color.white                // White - card surfaces
    static let sgfSurfaceSecondary = Color(hex: "E8E0D5") // Sand Dark - elevated surfaces

    // MARK: - Text Colors
    static let sgfTextPrimary = Color(hex: "2E2E2E")   // Deep Charcoal - primary text
    static let sgfTextSecondary = Color(hex: "5A5A5A") // Charcoal Light - secondary text
    static let sgfTextTertiary = Color(hex: "8A8A8A")  // Charcoal Lighter - placeholder text, captions

    // MARK: - Extended Palette (Derived)
    static let sgfTerracottaLight = Color(hex: "C98F7A") // Terracotta Light - hover states, subtle backgrounds
    static let sgfTerracottaDark = Color(hex: "8B4030")  // Terracotta Dark - pressed states, emphasis
    static let sgfBlueLight = Color(hex: "9FB5BE")       // Blue Light - secondary hover, calm highlights
    static let sgfBlueDark = Color(hex: "4A6A78")        // Blue Dark - pressed states for blue elements
    static let sgfClayLight = Color(hex: "E8D4C5")       // Clay Light - soft backgrounds, cards
    static let sgfSandDark = Color(hex: "E8E0D5")        // Sand Dark - card backgrounds, dividers
    static let sgfCharcoalLight = Color(hex: "5A5A5A")   // Charcoal Light - secondary text
    static let sgfCharcoalLighter = Color(hex: "8A8A8A") // Charcoal Lighter - placeholder text

    // MARK: - Cycle Phase Colors
    static let sgfMenstrual = Color(hex: "B35C44")     // Deep Terracotta - warm, grounding, restful
    static let sgfFollicular = Color(hex: "6F8F9B")    // Dusty Blue - growth, calm renewal, rising energy
    static let sgfOvulatory = Color(hex: "D8B8A6")     // Soft Clay Neutral - peak warmth, gentle vitality
    static let sgfLuteal = Color(hex: "9B9A9A")        // Blue-Clay Blend - winding down, balanced introspection

    // MARK: - Semantic Colors
    static let sgfSuccess = Color(hex: "6F8F9B")       // Use dusty blue for success
    static let sgfWarning = Color(hex: "D8B8A6")       // Use soft clay for warnings
    static let sgfError = Color(hex: "B35C44")         // Use terracotta for errors

    // MARK: - Interactive States
    static var sgfPrimaryHover: Color { .sgfTerracottaLight }
    static var sgfPrimaryPressed: Color { .sgfTerracottaDark }
    static var sgfSecondaryHover: Color { .sgfBlueLight }
    static var sgfDivider: Color { .sgfSandDark }

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
// 8pt grid system

struct SGFSpacing {
    static let xs: CGFloat = 4      // Tight spacing, icon gaps
    static let sm: CGFloat = 8      // Related elements
    static let md: CGFloat = 16     // Standard padding
    static let lg: CGFloat = 24     // Section spacing
    static let xl: CGFloat = 32     // Major sections
    static let xxl: CGFloat = 48    // Screen margins, hero spacing
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
                    .fill(isDisabled ? Color.sgfTextTertiary : (configuration.isPressed ? Color.sgfPrimaryPressed : Color.sgfPrimary))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SGFSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sgfHeadline)
            .foregroundColor(configuration.isPressed ? .sgfPrimaryPressed : .sgfPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SGFSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .fill(configuration.isPressed ? Color.sgfPrimaryHover.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGFCornerRadius.md)
                    .stroke(configuration.isPressed ? Color.sgfPrimaryPressed : Color.sgfPrimary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
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
