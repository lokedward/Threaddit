// ContentView.swift
// Root view with navigation structure

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingSettings = false
    @State private var searchText = ""
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationStack {
            HomeView(searchText: $searchText, showingAddItem: $showingAddItem)
                .navigationTitle("Threaddit")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            SearchView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                        }
                    }
                }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ClothingItem.self, Category.self], inMemory: true)
}
