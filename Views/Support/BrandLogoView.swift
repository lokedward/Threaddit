// BrandLogoView.swift
// A minimalistic component to display the brand logo with subtle animations

import SwiftUI

struct BrandLogoView: View {
    var isAnimating: Bool = true
    var speed: Double = 1.5 // Duration of one fade cycle
    
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Image("brand_logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .opacity(opacity)
            .onAppear {
                if isAnimating {
                    withAnimation(
                        Animation.easeInOut(duration: speed)
                            .repeatForever(autoreverses: true)
                    ) {
                        opacity = 0.7
                    }
                } else {
                    opacity = 0.5
                }
            }
    }
}

#Preview {
    ZStack {
        PoshTheme.Colors.canvas.ignoresSafeArea()
        BrandLogoView(isAnimating: true)
            .frame(width: 200, height: 200)
    }
}
