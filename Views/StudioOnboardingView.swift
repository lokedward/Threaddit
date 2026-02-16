// StudioOnboardingView.swift
// First-time setup flow when users unlock the Studio

import SwiftUI

struct StudioOnboardingView: View {
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: OnboardingStep = .welcome
    @Binding var showPaywall: Bool
    
    enum OnboardingStep {
        case welcome
        case modelSetup
        case closetTour
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                PoshTheme.Colors.canvas.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach([OnboardingStep.welcome, .modelSetup, .closetTour], id: \.self) { step in
                            Rectangle()
                                .fill(currentStep == step || stepIndex(step) < stepIndex(currentStep) ? PoshTheme.Colors.gold : PoshTheme.Colors.stone)
                                .frame(height: 3)
                                .animation(.spring(response: 0.3), value: currentStep)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        WelcomeStepView(onContinue: {
                            withAnimation {
                                currentStep = .modelSetup
                            }
                        })
                        .tag(OnboardingStep.welcome)
                        
                        ModelSetupStepView(showPaywall: $showPaywall, onContinue: {
                            withAnimation {
                                currentStep = .closetTour
                            }
                        })
                        .tag(OnboardingStep.modelSetup)
                        
                        ClosetTourStepView(onComplete: {
                            onComplete()
                            dismiss()
                        })
                        .tag(OnboardingStep.closetTour)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onComplete()
                        dismiss()
                    } label: {
                        Text("SKIP")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(PoshTheme.Colors.ink.opacity(0.4))
                    }
                }
            }
        }
    }
    
    private func stepIndex(_ step: OnboardingStep) -> Int {
        switch step {
        case .welcome: return 0
        case .modelSetup: return 1
        case .closetTour: return 2
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(PoshTheme.Colors.gold.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundColor(PoshTheme.Colors.gold)
            }
            
            // Message
            VStack(spacing: 16) {
                Text("WELCOME TO THE STUDIO")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(3)
                    .foregroundColor(PoshTheme.Colors.ink)
                
                VStack(spacing: 12) {
                    Text("Your AI-powered styling assistant")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(PoshTheme.Colors.ink.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        OnboardingFeatureRow(icon: "person.fill", text: "Generate outfit photos with your items")
                        OnboardingFeatureRow(icon: "wand.and.stars", text: "Get AI styling suggestions for any occasion")
                        OnboardingFeatureRow(icon: "square.grid.2x2", text: "Filter items by category for easy selection")
                    }
                    .padding(.top, 8)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // CTA
            Button(action: onContinue) {
                Text("SET UP YOUR MODEL")
                    .tracking(2)
                    .frame(maxWidth: .infinity)
            }
            .poshButton()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(PoshTheme.Colors.gold)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(PoshTheme.Colors.ink.opacity(0.8))
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Model Setup Step

struct ModelSetupStepView: View {
    @Binding var showPaywall: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("CONFIGURE YOUR MODEL")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)
                    .foregroundColor(PoshTheme.Colors.ink)
                    .padding(.top, 20)
                
                Text("Help the AI generate photos that best represent you")
                    .font(.system(size: 12))
                    .foregroundColor(PoshTheme.Colors.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            // Embedded ProfileTabView content
            ProfileTabView(showPaywall: $showPaywall)
                .frame(maxHeight: .infinity)
            
            // CTA
            Button(action: onContinue) {
                Text("CONTINUE TO CLOSET")
                    .tracking(2)
                    .frame(maxWidth: .infinity)
            }
            .poshButton()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Closet Tour Step

struct ClosetTourStepView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(PoshTheme.Colors.gold.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 44))
                    .foregroundColor(PoshTheme.Colors.gold)
            }
            
            // Message
            VStack(spacing: 16) {
                Text("YOUR CLOSET")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(3)
                    .foregroundColor(PoshTheme.Colors.ink)
                
                VStack(spacing: 12) {
                    Text("Two ways to style")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(PoshTheme.Colors.ink)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        OnboardingFeatureRow(icon: "hand.tap.fill", text: "CLOSET tab: Manually select your items")
                        OnboardingFeatureRow(icon: "sparkles", text: "STYLING tab: Let AI pick your outfit")
                        OnboardingFeatureRow(icon: "slider.horizontal.3", text: "Use category filters to browse faster")
                    }
                    .padding(.top, 8)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // CTA
            Button(action: onComplete) {
                Text("START STYLING")
                    .tracking(2)
                    .frame(maxWidth: .infinity)
            }
            .poshButton()
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    StudioOnboardingView(onComplete: {}, showPaywall: .constant(false))
}
