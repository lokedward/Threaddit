// HomeView.swift
// Main closet view with category shelves and FAB

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.displayOrder) private var categories: [Category]
    @Binding var searchText: String
    @Binding var selectedTab: Int
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Computed property to check if the wardrobe is truly empty (no items in any category)
    private var isWardrobeEmpty: Bool {
        categories.allSatisfy { $0.items.isEmpty }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PoshTheme.Colors.canvas.ignoresSafeArea()
            
            if !hasCompletedOnboarding && isWardrobeEmpty {
                WelcomeOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(categories) { category in
                            CategoryShelfView(category: category, selectedTab: $selectedTab)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                }
            }
        }
    }
}

// Memory-retained EmptyClosetView removed in favor of WelcomeOnboardingView

#Preview {
    NavigationStack {
        HomeView(searchText: .constant(""), selectedTab: .constant(0))
    }
    .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
