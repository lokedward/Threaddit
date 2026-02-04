import SwiftUI
import UIKit

struct SharedImageCropperView: View {
    let image: UIImage
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cropSize = min(geometry.size.width, geometry.size.height) - 40
                
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    // Container for the image interactions
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .offset(offset)
                            .overlay(GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        viewSize = geo.size
                                        resetToFit(cropSize: cropSize, viewSize: geo.size)
                                    }
                            })
                    }
                    // Capture gestures on the whole background/container
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = max(scale * delta, 0.1) // Allow shrinking way down
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                withAnimation {
                                    validateState(cropSize: cropSize)
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                                withAnimation {
                                    validateState(cropSize: cropSize)
                                }
                            }
                    )
                    
                    // Crop overlay
                    SharedCropOverlay(cropSize: cropSize)
                        .allowsHitTesting(false) // Pass touches through
                }
            }
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Re-calculate crop params context
                        let geoWidth = UIScreen.main.bounds.width
                        let geoHeight = UIScreen.main.bounds.height
                        let shortSide = min(geoWidth, geoHeight)
                        let calculatedCropSize = shortSide - 40
                        
                        // Generate the final image
                        let cropped = renderFinalImage(cropSize: calculatedCropSize)
                        onSave(cropped)
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button("Reset") {
                        withAnimation {
                            resetToFit(cropSize: UIScreen.main.bounds.width - 40, viewSize: viewSize)
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func resetToFit(cropSize: CGFloat, viewSize: CGSize) {
        // Default to "Aspect Fit" inside the crop box?
        // Or "Aspect Fill" (current behavior)?
        // User wants Freedom. "Fit" is a safer starting point if they want to see everything.
        // But traditionally croppers start at "Fill".
        // Let's stick to Fill as default, but allow zomming out.
        
        scale = 1.0
        offset = .zero
        lastOffset = .zero
        
        let imgW = viewSize.width
        let imgH = viewSize.height
        
        // If image is smaller than cropbox (e.g. tiny icon), scale up to fill at least one dimension
        if imgW < cropSize && imgH < cropSize {
            let ratio = cropSize / min(imgW, imgH)
            scale = ratio
        } else {
            // Already fits 'aspect fit' by default SwiftUI rules
            // Let's enforce Fill
            // Calculate effective size at scale 1.0
            // viewSize comes from aspect ratio fit in screen.
            
            // To Fill the cropSize:
            let widthRatio = cropSize / imgW
            let heightRatio = cropSize / imgH
            scale = max(widthRatio, heightRatio)
        }
    }
    
    private func validateState(cropSize: CGFloat) {
        // "Full Freedom" Logic
        
        // 1. Minimum Zoom:
        // Don't enforce "Fill". Enforce "Fit"?
        // We want to at least be able to see the image.
        // Let's allow zooming out until the image is tiny?
        // Or maybe limit so at least one dimension matches cropSize? (Aspect Fit)
        // If we go smaller than Aspect Fit, it's just floating in space.
        
        let imgW = viewSize.width
        let imgH = viewSize.height
        
        // Calculate fit scale
        let fitScaleW = cropSize / imgW
        let fitScaleH = cropSize / imgH
        let fitScale = min(fitScaleW, fitScaleH)
        
        let minAllowedScale = fitScale * 0.8 // Allow a bit smaller than fit (margins)
        
        if scale < minAllowedScale {
            scale = minAllowedScale
        }
        
        if scale > 5.0 {
            scale = 5.0
        }
        
        // 2. Bound Panning
        // Image edges should not go PAST the crop box edges such that the image leaves the box completely.
        // Or, more strictly: The Image and CropBox must overlap.
        
        // Current rendered dimensions
        let currentW = imgW * scale
        let currentH = imgH * scale
        
        // Calculate max offsets
        // Center is (0,0).
        // CropBox bounds: -cropSize/2 ... +cropSize/2
        // Image bits bounds: offset - currentW/2 ... offset + currentW/2
        
        // If Image > CropBox:
        // We usually want CropBox to be FULLY inside Image (no black bars).
        // BUT user asked for freedom. So we allow black bars.
        // So we only constrain so the image doesn't fly away.
        // Let's constrain centers?
        // Limit offset so center of image is within cropbox?
        // offset limit = cropSize / 2 + currentW / 2 ? No that's touching edges.
        
        // Let's try: No hard constraints on Pan other than "don't lose it".
        // Limit center of image to be within the crop box frame?
        
        let limitX = (cropSize / 2) + (currentW / 2) - 20 // Keep at least 20px overlap
        let limitY = (cropSize / 2) + (currentH / 2) - 20
        
        if abs(offset.width) > limitX {
            offset.width = limitX * (offset.width > 0 ? 1 : -1)
        }
        if abs(offset.height) > limitY {
            offset.height = limitY * (offset.height > 0 ? 1 : -1)
        }
        
        // If user wants STRICT crop-to-corners behavior (standard web cropper), 
        // they usually mean: "I can drag the corner handles".
        // Here we have fixed box, moving image.
        // If I zoom out (Image < CropBox), I have black bars.
        // If I zoom in (Image > CropBox), I can pan.
        
        lastOffset = offset
        lastScale = 1.0
    }
    
    private func renderFinalImage(cropSize: CGFloat) -> UIImage {
        let img = image.fixedOrientation()
        
        // We are rendering what is visibly inside the CropBox into a new Image.
        // Output size will be cropSize * screenScale? 
        // Or just cropSize points?
        // Let's go for high res.
        
        // Base resolution: standardizing output to e.g. 1024x1024 or based on source image?
        // If we just want the crop, we should map the crop pixels.
        
        // But if we allowed "Zoom out" (black bars), we can't just slice the original image.
        // We must draw the original image onto a canvas.
        
        // Canvas Size:
        // If we want 1:1 output.
        // Let's use 1080x1080 as a good standard for closet items.
        let targetSize = CGSize(width: 1080, height: 1080)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { context in
            // Fill black background (or transparent?)
            // Products usually look better with white or transparent? 
            // User app seems to use standard background? 
            // Let's use white for clean look, or keep transparent if PNG.
            // Let's clear context.
            // UIColor.white.setFill(); context.fill(CGRect(origin: .zero, size: targetSize))
            
            // Calculate where the image goes in this 1080x1080 frame.
            
            // Map Screen CropBox -> Target Canvas
            // scaleFactor = targetSize.width / cropSize
            let outputScale = targetSize.width / cropSize
            
            // Image Properties
            let imgW = viewSize.width
            let imgH = viewSize.height
            
            // Image current rendered rect relative to CropBox Center
            // Scale: self.scale
            // Offset: self.offset
            
            let currentRenderedW = imgW * scale
            let currentRenderedH = imgH * scale
            
            // Position of Image TopLeft relative to CropBox TopLeft
            // CropBox Center = (cropSize/2, cropSize/2) in CropBox Space
            // Image Center = CropBox Center + offset
            
            let imgCenterX = (cropSize / 2) + offset.width
            let imgCenterY = (cropSize / 2) + offset.height
            
            let imgTopLeftX = imgCenterX - (currentRenderedW / 2)
            let imgTopLeftY = imgCenterY - (currentRenderedH / 2)
            
            // Now Scale up to Target Space
            let finalX = imgTopLeftX * outputScale
            let finalY = imgTopLeftY * outputScale
            let finalW = currentRenderedW * outputScale
            let finalH = currentRenderedH * outputScale
            
            let destRect = CGRect(x: finalX, y: finalY, width: finalW, height: finalH)
            
            img.draw(in: destRect)
        }
    }
}

struct SharedCropOverlay: View {
    let cropSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .mask(
                        ZStack {
                            Rectangle()
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: cropSize, height: cropSize)
                                .position(x: centerX, y: centerY)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    )
                
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: cropSize, height: cropSize)
                    .position(x: centerX, y: centerY)
                
                Path { path in
                    let third = cropSize / 3
                    let left = centerX - cropSize / 2
                    let top = centerY - cropSize / 2
                    
                    path.move(to: CGPoint(x: left + third, y: top))
                    path.addLine(to: CGPoint(x: left + third, y: top + cropSize))
                    path.move(to: CGPoint(x: left + third * 2, y: top))
                    path.addLine(to: CGPoint(x: left + third * 2, y: top + cropSize))
                    
                    path.move(to: CGPoint(x: left, y: top + third))
                    path.addLine(to: CGPoint(x: left + cropSize, y: top + third))
                    path.move(to: CGPoint(x: left, y: top + third * 2))
                    path.addLine(to: CGPoint(x: left + cropSize, y: top + third * 2))
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            }
        }
    }
}
