// StylistView.swift
// Main container for the AI Stylist feature

import SwiftUI
import SwiftData

struct StylistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var items: [ClothingItem]
    
    @State private var selectedItems: Set<UUID> = []
    @State private var showingSelection = true
    @AppStorage("stylistModelGender") private var genderRaw = "female"
    @State private var showSettings = false
    
    // AI Suggestion State
    @AppStorage("stylistOccasion") private var occasionRaw = StylistOccasion.casual.rawValue
    @AppStorage("stylistCustomOccasion") private var customOccasion = ""
    @State private var isStyling = false
    
    // Computed property to sync local state with AppStorage
    private var modelGender: Gender {
        genderRaw == "male" ? .male : .female
    }
    
    var body: some View {
        ZStack {
            PoshTheme.Colors.canvas.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Styling Canvas
                StylingCanvasView(
                    selectedItems: items.filter { selectedItems.contains($0.id) },
                    gender: modelGender
                )
                .frame(maxHeight: .infinity)
                .overlay {
                    if isStyling {
                        ProcessingOverlayView(message: "Stylist is thinking...")
                    }
                }
                
                // Bottom Selection Drawer/Grid
                VStack(spacing: 0) {
                    Divider()
                        .background(PoshTheme.Colors.ink.opacity(0.1))
                    
                    
                    HStack {
                        HStack(spacing: 6) {
                            Text("YOUR CLOSET")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(PoshTheme.Colors.ink.opacity(0.6))
                            
                            if !selectedItems.isEmpty {
                                Text("(\(selectedItems.count))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(PoshTheme.Colors.ink)
                            }
                            }
                        }
                        
                        Spacer()
                        
                        if !items.isEmpty {
                            Button {
                                performAISuggestion()
                            } label: {
                                HStack(spacing: 6) {
                                    Text("STYLE ME!").font(.system(size: 10, weight: .bold)).tracking(1)
                                    Image(systemName: "sparkles")
                                }
                                .foregroundColor(PoshTheme.Colors.ink)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(PoshTheme.Colors.ink.opacity(0.05))
                                .clipShape(Capsule())
                            }
                            .disabled(isStyling)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring()) {
                                showingSelection.toggle()
                            }
                        } label: {
                            Image(systemName: showingSelection ? "chevron.down" : "chevron.up")
                                .foregroundColor(PoshTheme.Colors.ink)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.5))
                    
                    if showingSelection {
                        ItemSelectionGridView(
                            items: items,
                            selectedItems: $selectedItems
                        )
                        .transition(.move(edge: .bottom))
                        .frame(maxHeight: 350)
                    }
                }
                .background(.ultraThinMaterial)
                .poshCard()
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("THE STUDIO").poshHeadline(size: 18)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(PoshTheme.Colors.ink)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            StylistSettingsView()
                .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - AI Selection Logic
    
    private func performAISuggestion() {
        let targetOccasion = occasionRaw == StylistOccasion.custom.rawValue ? customOccasion : occasionRaw
        
        isStyling = true
        Task {
            do {
                let suggestedIDs = try await StylistService.shared.suggestOutfit(for: targetOccasion, availableItems: items)
                await MainActor.run {
                    withAnimation(.spring()) {
                        self.selectedItems = suggestedIDs
                        self.showingSelection = false // Focus on the canvas
                    }
                    self.isStyling = false
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } catch {
                print("❌ Styling Error: \(error)")
                await MainActor.run {
                    self.isStyling = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StylistView()
    }
    .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
