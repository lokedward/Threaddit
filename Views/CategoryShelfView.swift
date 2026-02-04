// CategoryShelfView.swift
// Horizontal scrolling shelf for a category

import SwiftUI
import SwiftData

struct CategoryShelfView: View {
    let category: Category
    
    private var sortedItems: [ClothingItem] {
        category.items.sorted { $0.dateAdded > $1.dateAdded }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(category.name)
                    .font(.title3.weight(.semibold))
                
                Text("\(category.items.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
                
                Spacer()
                
                NavigationLink {
                    CategoryGridView(category: category)
                } label: {
                    Text("See All")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            // Horizontal scroll of items
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(sortedItems) { item in
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            ItemThumbnailView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Category.self, ClothingItem.self, configurations: config)
    
    let category = Category(name: "Tops", displayOrder: 0)
    container.mainContext.insert(category)
    
    return NavigationStack {
        CategoryShelfView(category: category)
    }
    .modelContainer(container)
}
