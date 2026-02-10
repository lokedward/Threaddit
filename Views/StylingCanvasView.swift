// StylingCanvasView.swift
// View for generating AI-styled model photos

import SwiftUI

struct StylingCanvasView: View {
    let selectedItems: [ClothingItem]
    let gender: StylistView.Gender
    
    @State private var generatedImage: UIImage?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                colors: [PoshTheme.Colors.primaryAccentEnd.opacity(0.05), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            
            if let generated = generatedImage {
                // Show generated model photo
                VStack {
                    Image(uiImage: generated)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .poshCard()
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    
                    // Regenerate button
                    Button {
                        generatedImage = nil
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("TRY DIFFERENT LOOK")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(PoshTheme.Colors.primaryAccentStart)
                    }
                    .padding(.bottom)
                }
            } else if selectedItems.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundColor(PoshTheme.Colors.primaryAccentStart)
                    
                    Text("SELECT PIECES TO START STYLING")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(PoshTheme.Colors.secondaryAccent.opacity(0.6))
                }
            } else if isGenerating {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(PoshTheme.Colors.primaryAccentStart)
                    
                    Text("GENERATING YOUR LOOK...")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .foregroundColor(PoshTheme.Colors.secondaryAccent)
                    
                    Text("This may take 10-20 seconds")
                        .poshBody(size: 12)
                        .foregroundColor(PoshTheme.Colors.secondaryAccent.opacity(0.6))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .poshCard()
            } else {
                // Ready to generate - show mannequin + button
                VStack {
                    Spacer()
                    
                    // Model placeholder
                    Image(systemName: gender == .female ? "figure.stand.dress" : "figure.stand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 350)
                        .foregroundColor(PoshTheme.Colors.secondaryAccent.opacity(0.1))
                    
                    Spacer()
                    
                    // Generate Button
                    Button {
                        generateLook()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                            Text("GENERATE LOOK")
                                .tracking(2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .poshButton()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
            
            // Error overlay
            if let error = errorMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .poshBody(size: 12)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .poshCard()
                    .padding()
                    .transition(.move(edge: .bottom))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            errorMessage = nil
                        }
                    }
                }
            }
        }
    }
    
    private func generateLook() {
        guard !selectedItems.isEmpty else { return }
        
        errorMessage = nil
        isGenerating = true
        
        Task {
            do {
                let image = try await StylistService.shared.generateModelPhoto(
                    items: selectedItems,
                    gender: gender == .female ? .female : .male
                )
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        generatedImage = image
                        isGenerating = false
                    }
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    withAnimation {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    StylingCanvasView(selectedItems: [], gender: .female)
}
