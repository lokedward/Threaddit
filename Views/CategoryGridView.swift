// CategoryGridView.swift
// Full-screen grid view for all items in a category

import SwiftUI
import SwiftData

struct CategoryGridView: View {
    let category: Category
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var sortedItems: [ClothingItem] {
        category.items.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        ScrollView {
            if sortedItems.isEmpty {
                VStack(spacing: 16) {
                    Spacer(minLength: 100)
                    
                    Image(systemName: "tshirt")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No items in \(category.name)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add items using the + button")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(sortedItems) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            ItemThumbnailView(item: item, size: .large)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Category.self, ClothingItem.self, configurations: config)
    
    let category = Category(name: "Tops", displayOrder: 0)
    container.mainContext.insert(category)
    
    return NavigationStack {
        CategoryGridView(category: category)
    }
    .modelContainer(container)
}
