// StylistSettings.swift
// Models and Views for dynamic stylist configuration

import SwiftUI

// MARK: - Enums

enum ModelBodyType: String, CaseIterable, Identifiable {
    case slim = "Slim"
    case athletic = "Athletic"
    case curvy = "Curvy"
    case plusSize = "Plus Size"
    
    var id: String { rawValue }
    
    var promptDescription: String {
        switch self {
        case .slim: return "slim build"
        case .athletic: return "athletic build"
        case .curvy: return "curvy full-figured build"
        case .plusSize: return "plus-size full-figured build"
        }
    }
}

enum SkinTone: String, CaseIterable, Identifiable {
    case fair = "Fair"
    case medium = "Medium"
    case olive = "Olive"
    case dark = "Dark"
    case deep = "Deep"
    
    var id: String { rawValue }
    
    var promptDescription: String {
        switch self {
        case .fair: return "fair skin tone"
        case .medium: return "medium skin tone"
        case .olive: return "olive skin tone"
        case .dark: return "dark skin tone"
        case .deep: return "deep skin tone"
        }
    }
    
    var color: Color {
        switch self {
        case .fair: return Color(red: 0.95, green: 0.85, blue: 0.80)
        case .medium: return Color(red: 0.85, green: 0.70, blue: 0.60)
        case .olive: return Color(red: 0.75, green: 0.60, blue: 0.45)
        case .dark: return Color(red: 0.55, green: 0.40, blue: 0.30)
        case .deep: return Color(red: 0.35, green: 0.25, blue: 0.20)
        }
    }
}

enum ModelHeight: String, CaseIterable, Identifiable {
    case petite = "Petite"
    case average = "Average"
    case tall = "Tall"
    
    var id: String { rawValue }
    
    var promptDescription: String {
        switch self {
        case .petite: return "petite height"
        case .average: return "average height"
        case .tall: return "tall height"
        }
    }
}

enum StylistOccasion: String, CaseIterable, Identifiable {
    case casual = "Casual"
    case professional = "Professional"
    case dateNight = "Date Night"
    case formal = "Formal/Wedding"
    case vacation = "Vacation"
    case gym = "Athletic/Gym"
    case custom = "Custom..."
    
    var id: String { rawValue }
}

// MARK: - Settings View

struct StylistSettingsView: View {
    @AppStorage("stylistModelGender") private var genderRaw = "female"
    @AppStorage("stylistBodyType") private var bodyTypeRaw = ModelBodyType.slim.rawValue
    @AppStorage("stylistSkinTone") private var skinToneRaw = SkinTone.medium.rawValue
    @AppStorage("stylistModelHeight") private var heightRaw = ModelHeight.average.rawValue
    
    @AppStorage("stylistOccasion") private var occasionRaw = StylistOccasion.casual.rawValue
    @AppStorage("stylistCustomOccasion") private var customOccasion = ""
    
    var onStyleMe: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                modelProfileSection
                appearanceSection
                stylingOccasionSection
                footerSection
            }
            .scrollContentBackground(.hidden)
            .background(PoshTheme.Colors.canvas)
            .navigationTitle("Stylist Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(PoshTheme.Colors.ink)
                }
            }
        }
    }
    
    private var stylingOccasionSection: some View {
        Section("Target Occasion") {
            Picker("Occasion", selection: $occasionRaw) {
                ForEach(StylistOccasion.allCases) { occasion in
                    Text(occasion.rawValue).tag(occasion.rawValue)
                }
            }
            
            if occasionRaw == StylistOccasion.custom.rawValue {
                TextField("E.g. 90s Disco Party", text: $customOccasion)
                    .font(.system(size: 15))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("The Stylist will prioritize items in your closet that fit this vibe, try our smart stylist feature below:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Button {
                    dismiss()
                    onStyleMe?()
                } label: {
                    HStack(spacing: 8) {
                        Text("STYLE ME!")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                        Image(systemName: "sparkles")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(PoshTheme.Colors.ink)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.white)
    }
    
    private var modelProfileSection: some View {
        Section("Model Profile") {
            Picker("Gender", selection: $genderRaw) {
                Text("Female").tag("female")
                Text("Male").tag("male")
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .padding(.vertical, 4)
            
            Picker("Body Type", selection: $bodyTypeRaw) {
                ForEach(ModelBodyType.allCases) { type in
                    Text(type.rawValue).tag(type.rawValue)
                }
            }
            
            Picker("Height", selection: $heightRaw) {
                ForEach(ModelHeight.allCases) { height in
                    Text(height.rawValue).tag(height.rawValue)
                }
            }
        }
        .listRowBackground(Color.white)
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Skin Tone")
                
                HStack(spacing: 12) {
                    ForEach(SkinTone.allCases) { tone in
                        Circle()
                            .fill(tone.color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(PoshTheme.Colors.gold, lineWidth: tone.rawValue == skinToneRaw ? 3 : 0)
                            )
                            .onTapGesture {
                                skinToneRaw = tone.rawValue
                            }
                    }
                }
                .padding(.bottom, 4)
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Color.white)
    }
    
    private var footerSection: some View {
        Section {
            Text("These settings help the AI generate a model that best represents you or your desired look.")
                .font(.caption)
                .foregroundColor(.secondary)
                .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    StylistSettingsView()
}
