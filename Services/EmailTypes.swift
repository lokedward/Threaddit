// EmailTypes.swift
// Shared types for Email Onboarding feature

import Foundation

// MARK: - Enums & Errors

enum EmailError: LocalizedError {
    case tierRestriction
    case authenticationFailed
    case apiError(String)
    case parsingFailed
    case notImplemented
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .tierRestriction:
            return "This time range requires Premium. Upgrade to import from the last 2 years!"
        case .authenticationFailed:
            return "Failed to connect to Gmail. Please try again."
        case .apiError(let message):
            return "Gmail API error: \(message)"
        case .parsingFailed:
            return "Failed to extract products from emails"
        case .notImplemented:
            return "This feature is under development"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

enum ImportPhase {
    case authenticating
    case searching
    case parsing
    case downloading
    case complete
    
    var displayText: String {
        switch self {
        case .authenticating:
            return "Connecting to Gmail..."
        case .searching:
            return "Searching for order emails..."
        case .parsing:
            return "Extracting products..."
        case .downloading:
            return "Downloading images..."
        case .complete:
            return "Complete!"
        }
    }
}

struct ImportProgress {
    var phase: ImportPhase
    var totalEmails: Int
    var processedEmails: Int
    var foundItems: Int = 0
    var currentRetailer: String?
    var detailMessage: String?
    
    var percentComplete: Double {
        guard totalEmails > 0 else { return 0 }
        return Double(processedEmails) / Double(totalEmails)
    }
}

enum TimeRange: Equatable {
    case sixMonths   // Free tier
    case twoYears    // Premium
    case custom(Date) // Premium+
    
    var gmailTimeFilter: String {
        switch self {
        case .sixMonths:
            return "newer_than:6m"
        case .twoYears:
            return "newer_than:2y"
        case .custom(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            return "after:\(formatter.string(from: date))"
        }
    }
    
    var displayName: String {
        switch self {
        case .sixMonths:
            return "Last 6 months"
        case .twoYears:
            return "Last 2 years"
        case .custom(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Since \(formatter.string(from: date))"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .sixMonths:
            return false
        case .twoYears, .custom:
            return true
        }
    }
}

// MARK: - Data Models

struct GmailToken {
    let accessToken: String
    let expiresAt: Date
}

struct GmailMessage {
    let id: String
    let from: String
    let subject: String
    let date: Date
    let htmlBody: String?
}

struct ProductData: Identifiable {
    let id = UUID()
    let name: String
    let imageURL: URL
    let price: String?
    let brand: String?
    let size: String?
    let color: String?
    let category: String?
    let tags: [String]
    var score: Int = 0 
}
