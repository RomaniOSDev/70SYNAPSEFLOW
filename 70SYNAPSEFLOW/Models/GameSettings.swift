//
//  GameSettings.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Difficulty Level
enum DifficultyLevel: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var signalRatio: Double {
        switch self {
        case .easy: return 0.85  // 85% signals
        case .medium: return 0.70  // 70% signals
        case .hard: return 0.55   // 55% signals
        }
    }
    
    var spawnInterval: TimeInterval {
        switch self {
        case .easy: return 2.0
        case .medium: return 1.5
        case .hard: return 1.0
        }
    }
    
    var neuronSpeed: CGFloat {
        switch self {
        case .easy: return 4.0
        case .medium: return 6.0
        case .hard: return 8.0
        }
    }
    
    var gameDuration: TimeInterval {
        switch self {
        case .easy: return 90.0
        case .medium: return 60.0
        case .hard: return 45.0
        }
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let unlockedAt: Date?
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, unlockedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.unlockedAt = unlockedAt
    }
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}

// MARK: - Achievement Types
enum AchievementType: String, Codable {
    case perfectRound      // 100% accuracy
    case speedMaster       // Very fast reaction time
    case marathon          // Complete 10 tests
    case consistency       // 7 day streak
    case earlyBird         // Complete morning test 5 times
    case nightOwl          // Complete evening test 5 times
    case highScore         // Score over 500
    case focusMaster       // Complete hard difficulty
}

// MARK: - User Settings
class UserSettings: ObservableObject, Codable {
    @Published var difficulty: DifficultyLevel = .medium
    @Published var soundEnabled: Bool = true
    @Published var notificationsEnabled: Bool = true
    @Published var testDuration: TimeInterval = 60.0
    
    enum CodingKeys: String, CodingKey {
        case difficulty, soundEnabled, notificationsEnabled, testDuration
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        difficulty = try container.decode(DifficultyLevel.self, forKey: .difficulty)
        soundEnabled = try container.decode(Bool.self, forKey: .soundEnabled)
        notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)
        testDuration = try container.decode(TimeInterval.self, forKey: .testDuration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(soundEnabled, forKey: .soundEnabled)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(testDuration, forKey: .testDuration)
    }
    
    init() {}
}

// MARK: - Task Category
enum TaskCategory: String, Codable, CaseIterable {
    case work
    case study
    case creative
    case exercise
    case rest
    case other
    
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .study: return "Study"
        case .creative: return "Creative"
        case .exercise: return "Exercise"
        case .rest: return "Rest"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .creative: return "paintbrush.fill"
        case .exercise: return "figure.run"
        case .rest: return "bed.double.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .study: return Color(red: 0.6, green: 0.3, blue: 1.0)
        case .creative: return Color(red: 1.0, green: 0.5, blue: 0.2)
        case .exercise: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .rest: return GameConstants.noiseColor
        case .other: return Color.gray
        }
    }
}

// MARK: - Streak
struct Streak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastTestDate: Date?
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastTestDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysSince = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysSince == 1 {
                // Consecutive day
                currentStreak += 1
            } else if daysSince > 1 {
                // Streak broken
                currentStreak = 1
            }
            // daysSince == 0 means same day, don't increment
        } else {
            // First test
            currentStreak = 1
        }
        
        lastTestDate = today
        longestStreak = max(longestStreak, currentStreak)
    }
}

// MARK: - Motivational Quote
struct MotivationalQuote: Identifiable {
    let id = UUID()
    let text: String
    let author: String?
    
    static let quotes: [MotivationalQuote] = [
        MotivationalQuote(text: "Focus is not about saying yes to everything. It's about saying no to all but the essential.", author: "Steve Jobs"),
        MotivationalQuote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
        MotivationalQuote(text: "Your brain is your most powerful tool. Train it well.", author: nil),
        MotivationalQuote(text: "Small steps every day lead to big changes over time.", author: nil),
        MotivationalQuote(text: "Productivity is never an accident. It's always the result of commitment to excellence.", author: nil),
        MotivationalQuote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        MotivationalQuote(text: "Focus on progress, not perfection.", author: nil),
        MotivationalQuote(text: "Your cognitive performance is a reflection of your daily habits.", author: nil)
    ]
    
    static func random() -> MotivationalQuote {
        quotes.randomElement() ?? quotes[0]
    }
}
