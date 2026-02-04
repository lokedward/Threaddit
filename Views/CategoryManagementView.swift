// CategoryManagementView.swift
// Add, edit, reorder, and delete categories

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.displayOrder) private var categories: [Category]
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var editingCategory: Category?
    @State private var editCategoryName = ""
    @State private var categoryToDelete: Category?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        List {
            Section {
                ForEach(categories) { category in
                    HStack {
                        Text(category.name)
                        
                        Spacer()
                        
                        Text("\(category.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button {
                            editingCategory = category
                            editCategoryName = category.name
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            categoryToDelete = category
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove(perform: moveCategories)
            } header: {
                Text("Long press to rename or delete")
            } footer: {
                Text("Drag to reorder categories. Items in deleted categories will become uncategorized.")
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .alert("Add Category", isPresented: $showingAddCategory) {
            TextField("Category name", text: $newCategoryName)
            
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
            
            Button("Add") {
                addCategory()
            }
            .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .alert("Rename Category", isPresented: Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )) {
            TextField("Category name", text: $editCategoryName)
            
            Button("Cancel", role: .cancel) {
                editingCategory = nil
                editCategoryName = ""
            }
            
            Button("Save") {
                saveRename()
            }
            .disabled(editCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .alert("Delete Category?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    deleteCategory(category)
                }
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            if let category = categoryToDelete {
                Text("Deleting \"\(category.name)\" will move \(category.items.count) items to uncategorized.")
            }
        }
    }
    
    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let maxOrder = categories.map(\.displayOrder).max() ?? -1
        let category = Category(name: trimmedName, displayOrder: maxOrder + 1)
        modelContext.insert(category)
        
        newCategoryName = ""
    }
    
    private func saveRename() {
        guard let category = editingCategory else { return }
        let trimmedName = editCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        category.name = trimmedName
        editingCategory = nil
        editCategoryName = ""
    }
    
    private func deleteCategory(_ category: Category) {
        // Items will have their category set to nil due to nullify delete rule
        modelContext.delete(category)
        categoryToDelete = nil
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        var orderedCategories = categories
        orderedCategories.move(fromOffsets: source, toOffset: destination)
        
        for (index, category) in orderedCategories.enumerated() {
            category.displayOrder = index
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
    }
    .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
