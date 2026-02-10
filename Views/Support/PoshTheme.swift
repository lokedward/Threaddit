// PoshTheme.swift
// Design tokens and styling rules for the high-end boutique aesthetic
// Light mode only - elegant champagne/gold color scheme

import SwiftUI

struct PoshTheme {
    // MARK: - Colors
    
    struct Colors {
        // Backgrounds
        static let background = Color(red: 0.98, green: 0.977, blue: 0.965)
        static let cardBackground = Color.white
        
        // Accents - Primary (Champagne/Gold)
        static let primaryAccentStart = Color(red: 0.83, green: 0.68, blue: 0.21) // Champagne
        static let primaryAccentEnd = Color(red: 0.91, green: 0.82, blue: 0.48)
        
        static var primaryGradient: LinearGradient {
            LinearGradient(colors: [primaryAccentStart, primaryAccentEnd], 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing)
        }
        
        // Secondary Accents
        static let secondaryAccent = Color(red: 0.85, green: 0.75, blue: 0.65)
        
        // Text
        static let headline = Color(red: 0.18, green: 0.14, blue: 0.12)
        static let body = Color(red: 0.36, green: 0.33, blue: 0.31)
        
        // Shadows
        static var cardShadow: Color {
            Color.black.opacity(0.08)
        }
    }
    
    // MARK: - Typography
    
    struct Typography {
        static func headline(size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .serif)
        }
        
        static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .default)
        }
    }
}

// MARK: - View Modifiers

struct PoshCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PoshTheme.Colors.cardBackground)
            .cornerRadius(16)
            .shadow(
                color: PoshTheme.Colors.cardShadow,
                radius: 10,
                x: 0,
                y: 5
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PoshTheme.Colors.secondaryAccent.opacity(0.2), lineWidth: 0.5)
            )
    }
}

struct PoshButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(PoshTheme.Colors.primaryGradient)
            .cornerRadius(30)
            .shadow(color: PoshTheme.Colors.primaryAccentStart.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func poshCard() -> some View {
        modifier(PoshCardModifier())
    }
    
    func poshButton() -> some View {
        modifier(PoshButtonModifier())
    }
    
    func poshHeadline(size: CGFloat = 24) -> some View {
        self.font(PoshTheme.Typography.headline(size: size))
            .foregroundColor(PoshTheme.Colors.headline)
    }
    
    func poshBody(size: CGFloat = 16, weight: Font.Weight = .regular) -> some View {
        self.font(PoshTheme.Typography.body(size: size, weight: weight))
            .foregroundColor(PoshTheme.Colors.body)
    }
}

// MARK: - Reusable Components

struct PoshHeader: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image("app_icon") // This will use Icons/app_icon.png if properly added to assets
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 28, height: 28)
            
            Text(title)
                .poshHeadline(size: 24)
        }
    }
}
