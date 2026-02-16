// StudioLockoutView.swift
// Lockout screen shown when user has fewer than 3 items in their wardrobe

import SwiftUI

struct StudioLockoutView: View {
    let itemCount: Int
    @Environment(\.dismiss) private var dismiss
    
    private var itemsRemaining: Int {
        max(0, 3 - itemCount)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Lock Icon
            ZStack {
                Circle()
                    .fill(PoshTheme.Colors.stone)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundColor(PoshTheme.Colors.ink.opacity(0.3))
            }
            
            // Message
            VStack(spacing: 16) {
                Text("AI STUDIO LOCKED")
                    .font(.system(size: 18, weight: .bold))
                    .tracking(3)
                    .foregroundColor(PoshTheme.Colors.ink)
                
                VStack(spacing: 8) {
                    Text("Studio features unlock with")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(PoshTheme.Colors.ink.opacity(0.7))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("3")
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .foregroundColor(PoshTheme.Colors.gold)
                        
                        Text("ITEMS")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(PoshTheme.Colors.ink.opacity(0.6))
                    }
                    
                    Text("uploaded to your closet")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(PoshTheme.Colors.ink.opacity(0.7))
                }
            }
            .multilineTextAlignment(.center)
            
            // Progress
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index < itemCount ? PoshTheme.Colors.gold : PoshTheme.Colors.stone)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .strokeBorder(PoshTheme.Colors.ink.opacity(0.1), lineWidth: 1)
                            )
                    }
                }
            }
            
            Spacer()
            
            // CTA
            Text("\(itemCount) of 3 items added")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(PoshTheme.Colors.ink.opacity(0.5))
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    NavigationStack {
        StudioLockoutView(itemCount: 1)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("THE STUDIO").poshHeadline(size: 18)
                }
            }
    }
}
