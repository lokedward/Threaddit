// LivingThreadView.swift
// Minimalist "Digital Knit" weaving for the Studio

import SwiftUI

struct LivingThreadView: View {
    var isGenerating: Bool = false
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Draw many ultra-thin threads to create a "knit" texture
                let horizontalCount = 12
                let verticalCount = 12
                
                // 1. Draw Horizontal "Threads"
                for i in 0..<horizontalCount {
                    drawThread(
                        context: context, 
                        size: size, 
                        index: i, 
                        total: horizontalCount,
                        time: time, 
                        isGenerating: isGenerating, 
                        isVertical: false
                    )
                }
                
                // 2. Draw Vertical "Threads"
                for i in 0..<verticalCount {
                    drawThread(
                        context: context, 
                        size: size, 
                        index: i, 
                        total: verticalCount,
                        time: time, 
                        isGenerating: isGenerating, 
                        isVertical: true
                    )
                }
            }
        }
    }
    
    private func drawThread(context: GraphicsContext, size: CGSize, index: Int, total: Int, time: Double, isGenerating: Bool, isVertical: Bool) {
        let speed = isGenerating ? 0.8 : 0.3
        let spread = isVertical ? size.width : size.height
        let pos = (spread / CGFloat(total + 1)) * CGFloat(index + 1)
        
        // Subtle drift animation
        let drift = sin(time * speed + Double(index) * 0.5) * (isGenerating ? 10.0 : 4.0)
        
        var path = Path()
        if isVertical {
            let x = pos + drift
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        } else {
            let y = pos + drift
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        let color = index % 5 == 0 ? PoshTheme.Colors.gold : PoshTheme.Colors.ink
        let opacity = isGenerating ? 0.15 : 0.08
        let lineWidth = 0.5 // Ultra-thin hair lines
        
        context.stroke(
            path,
            with: .color(color.opacity(opacity)),
            style: StrokeStyle(lineWidth: lineWidth)
        )
    }
}

#Preview {
    ZStack {
        PoshTheme.Colors.canvas.ignoresSafeArea()
        LivingThreadView(isGenerating: true)
            .frame(width: 300, height: 300)
    }
}
