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
            ZStack {
                PoshTheme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Categories Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ORGANIZATION")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(PoshTheme.Colors.secondaryAccent)
                            
                            NavigationLink {
                                CategoryManagementView()
                            } label: {
                                HStack {
                                    Label("MANAGE CATEGORIES", systemImage: "folder")
                                        .font(.system(size: 13, weight: .semibold))
                                        .tracking(1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(PoshTheme.Colors.secondaryAccent)
                                }
                                .padding()
                                .background(PoshTheme.Colors.cardBackground)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        
                        // Appearance Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("APPEARANCE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(PoshTheme.Colors.secondaryAccent)
                            
                            HStack {
                                Text("SYSTEM THEME")
                                    .font(.system(size: 13, weight: .semibold))
                                    .tracking(1)
                                Spacer()
                                Picker("", selection: $appearanceMode) {
                                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                        Text(mode.rawValue.uppercased()).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                            .padding()
                            .background(PoshTheme.Colors.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Stats Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ARCHIVE STATISTICS")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(PoshTheme.Colors.secondaryAccent)
                            
                            VStack(spacing: 12) {
                                PoshDetailRow(label: "TOTAL GARMENTS", value: "\(allItems.count)")
                                PoshDetailRow(label: "COLLECTIONS", value: "\(allCategories.count)")
                            }
                            .padding()
                            .background(PoshTheme.Colors.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Data Management Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DATA & PRIVACY")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(PoshTheme.Colors.secondaryAccent)
                            
                            VStack(spacing: 0) {
                                Button {
                                    exportData()
                                } label: {
                                    HStack {
                                        Label("EXPORT COLLECTION (JSON)", systemImage: "square.and.arrow.up")
                                            .font(.system(size: 13, weight: .semibold))
                                            .tracking(1)
                                        Spacer()
                                    }
                                    .padding()
                                }
                                
                                Divider().padding(.horizontal)
                                
                                Button(role: .destructive) {
                                    showingClearConfirmation = true
                                } label: {
                                    HStack {
                                        Label("CLEAR ALL DATA", systemImage: "trash")
                                            .font(.system(size: 13, weight: .bold))
                                            .tracking(1)
                                        Spacer()
                                    }
                                    .padding()
                                }
                            }
                            .background(PoshTheme.Colors.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // About
                        VStack(spacing: 8) {
                            Text("THREADLIST")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(3)
                                .foregroundColor(PoshTheme.Colors.secondaryAccent)
                            Text("VERSION 1.0.0")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(PoshTheme.Colors.secondaryAccent.opacity(0.6))
                        }
                        .padding(.top, 40)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS").font(.system(size: 14, weight: .bold)).tracking(2)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") { dismiss() }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(PoshTheme.Colors.primaryAccentStart)
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
        .poshHeadline(size: 16) // Reset some base text defaults if needed
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
