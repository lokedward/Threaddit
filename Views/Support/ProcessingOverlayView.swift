// ProcessingOverlayView.swift
// Reusable loading overlay with dynamic messages

import SwiftUI

struct ProcessingOverlayView: View {
    var message: String
    
    var body: some View {
        ZStack {
            // Soft dimming that matches our brand colors
            PoshTheme.Colors.ink.opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                LivingThreadView(isGenerating: true)
                    .frame(height: 120)
                
                Text(message.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(3)
                    .foregroundColor(PoshTheme.Colors.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 48)
            .background(Color.white)
            .poshCard()
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
}
