import SwiftUI
import SwiftData

struct WelcomeOnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var selectedTemplate: String? = nil
    @State private var pendingCategories: [String] = []
    
    var body: some View {
        ZStack {
            PoshTheme.Colors.canvas.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Top Navigation
                    HStack {
                        Spacer()
                        Button {
                            withAnimation { hasCompletedOnboarding = true }
                        } label: {
                            Text("SKIP")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundColor(PoshTheme.Colors.ink.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Hero Header
                    VStack(spacing: 8) {
                        Text("Your Digital Wardrobe")
                            .poshHeadline(size: 32)
                            .multilineTextAlignment(.center)
                        
                        Text("BUILD YOUR THREADLIST")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(3)
                            .foregroundColor(PoshTheme.Colors.ink.opacity(0.6))
                    }
                    .padding(.horizontal)
                    
                    if let selected = selectedTemplate {
                        // Feedback / Success State
                        VStack(spacing: 32) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 40, weight: .thin))
                                .foregroundColor(PoshTheme.Colors.ink)
                            
                            VStack(spacing: 12) {
                                Text("\(selected.uppercased()) READY")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(2)
                                
                                Text("We've drafted specialized shelves for your \(selected.lowercased()) categories.")
                                    .poshBody(size: 14)
                                    .opacity(0.6)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button {
                                finalizeOnboarding()
                            } label: {
                                Text("BUILD MY CLOSET")
                                    .tracking(2)
                            }
                            .poshButton()
                        }
                        .padding(40)
                        .background(Color.white)
                        .cornerRadius(24)
                        .poshCard()
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Starter Paths
                        VStack(alignment: .leading, spacing: 24) {
                            Text("SELECT YOUR WARDROBE STYLE")
                                .font(.system(size: 12, weight: .bold))
                                .tracking(2)
                                .foregroundColor(PoshTheme.Colors.ink.opacity(0.8))
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                TemplateRow(
                                    title: "Classic Essentials",
                                    subtitle: "Perfect for everyday basics & versatile pieces",
                                    categories: ["Tops", "Bottoms", "Outerwear", "Shoes"],
                                    icon: "square.grid.2x2",
                                    onSelect: { name, cats in
                                        selectedTemplate = name
                                        pendingCategories = cats
                                    }
                                )
                                
                                TemplateRow(
                                    title: "Athleisure",
                                    subtitle: "For active lifestyles & comfortable style",
                                    categories: ["Activewear", "Sneakers", "Performance", "Athleisure"],
                                    icon: "figure.run",
                                    onSelect: { name, cats in
                                        selectedTemplate = name
                                        pendingCategories = cats
                                    }
                                )
                                
                                TemplateRow(
                                    title: "Dressy & Refined",
                                    subtitle: "Elevated pieces for special occasions",
                                    categories: ["Formal", "Blazers", "Dress Shoes", "Accessories"],
                                    icon: "star.fill",
                                    onSelect: { name, cats in
                                        selectedTemplate = name
                                        pendingCategories = cats
                                    }
                                )
                            }
                            .padding(.horizontal)
                        }
                        .transition(.opacity)
                    }
                    
                    // Footer Hint
                    if selectedTemplate == nil {
                        Text("Choose a style to organize your wardrobe with custom categories.")
                            .poshBody(size: 13)
                            .opacity(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                    }
                }
                .animation(.spring(), value: selectedTemplate)
            }
        }
    }
    
    private func finalizeOnboarding() {
        for (index, name) in pendingCategories.enumerated() {
            // Check if category already exists to avoid duplicates
            let descriptor = FetchDescriptor<Category>(predicate: #Predicate<Category> { $0.name == name })
            if (try? modelContext.fetch(descriptor))?.isEmpty ?? true {
                let newCat = Category(name: name, displayOrder: index)
                modelContext.insert(newCat)
            }
        }
        
        try? modelContext.save()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Mark as completed to switch HomeView
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct TemplateRow: View {
    let title: String
    let subtitle: String
    let categories: [String]
    let icon: String
    let onSelect: (String, [String]) -> Void
    
    var body: some View {
        Button {
            // Haptic feedack on tap
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            onSelect(title, categories)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(PoshTheme.Colors.ink)
                        .frame(width: 56, height: 56)
                        .background(PoshTheme.Colors.stone)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(title.uppercased())
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(PoshTheme.Colors.ink)
                            
                            // Category count badge
                            Text("\(categories.count) CATEGORIES")
                                .font(.system(size: 8, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(PoshTheme.Colors.ink.opacity(0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(PoshTheme.Colors.stone)
                                .cornerRadius(4)
                        }
                        
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(PoshTheme.Colors.ink.opacity(0.6))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(PoshTheme.Colors.ink.opacity(0.3))
                        .font(.system(size: 16, weight: .semibold))
                }
                
                // Category tags
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(PoshTheme.Colors.ink.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(PoshTheme.Colors.stone.opacity(0.5))
                            .cornerRadius(6)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .poshCard()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WelcomeOnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [Category.self], inMemory: true)
}
