// LivingThreadView.swift
// Dynamic logo-based animation for the Studio

import SwiftUI

struct LivingThreadView: View {
    var isGenerating: Bool = false
    
    var body: some View {
        ZStack {
            // Draw multiple "threads" that write the logo out of sync for depth
            ForEach(0..<3) { i in
                AnimatedLogoTView(
                    color: i == 0 ? PoshTheme.Colors.gold : PoshTheme.Colors.ink,
                    lineWidth: i == 0 ? 3.0 : 1.5,
                    opacity: i == 0 ? 0.3 : 0.1,
                    delay: Double(i) * 0.4,
                    speedMultiplier: isGenerating ? 1.5 : 1.0
                )
                .offset(x: CGFloat(i * 4), y: CGFloat(i * 2))
                .blur(radius: i == 0 ? 0 : 0.5)
            }
        }
    }
}

struct ThreadditLogoT: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.width
        let h = rect.height
        
        // Scale and center the coordinates
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x / 100) * w, y: rect.minY + (y / 100) * h)
        }
        
        // --- 1. The Top Flourish (The "Thread" bar) ---
        path.move(to: p(15, 35))
        
        // Elegant top sweep
        path.addCurve(
            to: p(50, 20),
            control1: p(25, 25),
            control2: p(35, 18)
        )
        
        // Continue to right loop
        path.addCurve(
            to: p(85, 30),
            control1: p(65, 22),
            control2: p(80, 20)
        )
        
        // The right loop (where the needle eye would be)
        path.addCurve(
            to: p(70, 45),
            control1: p(95, 45),
            control2: p(80, 50)
        )
        path.addCurve(
            to: p(75, 25),
            control1: p(65, 40),
            control2: p(65, 30)
        )
        
        // --- 2. The Main Downstroke ---
        // We "jump" back to center top for the body
        path.move(to: p(55, 25))
        
        path.addCurve(
            to: p(45, 85),
            control1: p(75, 45),
            control2: p(35, 65)
        )
        
        // Bottom flourish loop
        path.addCurve(
            to: p(20, 75),
            control1: p(55, 100),
            control2: p(25, 95)
        )
        
        return path
    }
}

struct AnimatedLogoTView: View {
    @State private var writingProgress: CGFloat = 0
    let color: Color
    let lineWidth: CGFloat
    let opacity: Double
    let delay: Double
    let speedMultiplier: Double
    
    var body: some View {
        ThreadditLogoT()
            .trim(from: 0, to: writingProgress)
            .stroke(
                color.opacity(opacity),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.5 / speedMultiplier)
                        .delay(delay)
                        .repeatForever(autoreverses: true)
                ) {
                    writingProgress = 1.0
                }
            }
    }
}

#Preview {
    ZStack {
        PoshTheme.Colors.canvas.ignoresSafeArea()
        LivingThreadView(isGenerating: true)
            .frame(width: 300, height: 300)
    }
}
