// SettingsView.swift
// Settings menu with appearance and data management

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    
    @State private var showingClearConfirmation = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    
    @Query private var allItems: [ClothingItem]
    @Query private var allCategories: [Category]
    
    var body: some View {
        NavigationStack {
            List {
                // Categories Section
                Section {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("Manage Categories", systemImage: "folder")
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button {
                        exportData()
                    } label: {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }
                
                // Stats Section
                Section("Statistics") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(allItems.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Categories")
                        Spacer()
                        Text("\(allCategories.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear All Data?", isPresented: $showingClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your clothing items and custom categories. This cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }
    
    private func exportData() {
        var exportData: [[String: Any]] = []
        
        for item in allItems {
            var itemDict: [String: Any] = [
                "id": item.id.uuidString,
                "name": item.name,
                "dateAdded": ISO8601DateFormatter().string(from: item.dateAdded),
                "tags": item.tags
            ]
            
            if let brand = item.brand {
                itemDict["brand"] = brand
            }
            if let size = item.size {
                itemDict["size"] = size
            }
            if let category = item.category {
                itemDict["category"] = category.name
            }
            
            exportData.append(itemDict)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("threaddit_export.json")
            try jsonData.write(to: tempURL)
            
            exportURL = tempURL
            showingExportSheet = true
        } catch {
            print("Export error: \(error)")
        }
    }
    
    private func clearAllData() {
        // Delete all images
        for item in allItems {
            ImageStorageService.shared.deleteImage(withID: item.imageID)
        }
        
        // Delete all items
        for item in allItems {
            modelContext.delete(item)
        }
        
        // Delete custom categories (keep defaults)
        for category in allCategories {
            modelContext.delete(category)
        }
        
        // Re-seed defaults
        let defaultCategories = ["Tops", "Bottoms", "Outerwear", "Shoes", "Accessories"]
        for (index, name) in defaultCategories.enumerated() {
            let category = Category(name: name, displayOrder: index)
            modelContext.insert(category)
        }
    }
}

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// Share sheet for exporting
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
