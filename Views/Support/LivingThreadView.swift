// LivingThreadView.swift
// Dynamic procedural weaving animation for the Studio

import SwiftUI

struct LivingThreadView: View {
    var isGenerating: Bool = false
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Draw horizontal threads
                for i in 0..<6 {
                    drawThread(
                        context: context,
                        size: size,
                        index: i,
                        time: time,
                        isGenerating: isGenerating,
                        isVertical: false
                    )
                }
                
                // Draw vertical threads to create the "weaving" look
                for i in 0..<4 {
                    drawThread(
                        context: context,
                        size: size,
                        index: i,
                        time: time * 0.8, // Slightly different speed for variation
                        isGenerating: isGenerating,
                        isVertical: true
                    )
                }
            }
        }
    }
    
    private func drawThread(context: GraphicsContext, size: CGSize, index: Int, time: Double, isGenerating: Bool, isVertical: Bool) {
        let speed = isGenerating ? 2.5 : 1.0
        let amplitude = isGenerating ? 40.0 : 20.0
        let frequency = isVertical ? 0.008 : 0.005
        
        var path = Path()
        
        if isVertical {
            let startX = size.width * (0.3 + Double(index) * 0.15)
            path.move(to: CGPoint(x: startX, y: 0))
            
            for y in stride(from: 0, to: size.height, by: 5) {
                let relativePhase = Double(y) * frequency
                let timePhase = time * speed + Double(index)
                let x = startX + cos(relativePhase + timePhase) * (amplitude * 0.6)
                path.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
            }
        } else {
            let startY = size.height * (0.2 + Double(index) * 0.15)
            path.move(to: CGPoint(x: 0, y: startY))
            
            for x in stride(from: 0, to: size.width, by: 5) {
                let relativePhase = Double(x) * frequency
                let timePhase = time * speed + Double(index)
                let y = startY + sin(relativePhase + timePhase) * amplitude
                path.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
            }
        }
        
        let color = index % 3 == 0 ? PoshTheme.Colors.gold : PoshTheme.Colors.ink
        let opacity = isGenerating ? 0.3 : 0.1
        let lineWidth = isGenerating ? 1.5 : 0.5
        
        context.stroke(
            path,
            with: .color(color.opacity(opacity)),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        )
    }
}

#Preview {
    ZStack {
        PoshTheme.Colors.canvas.ignoresSafeArea()
        LivingThreadView(isGenerating: true)
    }
}
