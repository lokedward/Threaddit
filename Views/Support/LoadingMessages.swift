// LoadingMessages.swift
// Dynamic, witty messages for processing states

import Foundation

struct LoadingMessageService {
    static let shared = LoadingMessageService()
    
    enum LoadingContext {
        case magicFill
        case generation
        case styling
    }
    
    private let magicFillMessages = [
        "Sizing things up...",
        "Identifying these threads...",
        "Analyzing the weave...",
        "Checking the labels...",
        "Measuring twice, processing once...",
        "Giving these garments an identity...",
        "Consulting the tailoring gods...",
        "Cataloging your collection..."
    ]
    
    private let generationMessages = [
        "Polishing the runway...",
        "Adjusting the lighting...",
        "Making it seamless...",
        "Developing your signature look...",
        "A cut above the rest...",
        "Stitching the final pixels...",
        "Ensuring the perfect drape...",
        "Wait for the big reveal..."
    ]
    
    private let stylingMessages = [
        "Consulting the fashion icons...",
        "Browsing your virtual walk-in...",
        "Matching the vibe...",
        "Curating your silhouette...",
        "Ironing out the details...",
        "Lacing up the perfect fit...",
        "Finding your fashion future...",
        "Tying it all together..."
    ]
    
    func randomMessage(for context: LoadingContext) -> String {
        switch context {
        case .magicFill:
            return magicFillMessages.randomElement() ?? "Processing..."
        case .generation:
            return generationMessages.randomElement() ?? "Creating..."
        case .styling:
            return stylingMessages.randomElement() ?? "Styling..."
        }
    }
}
