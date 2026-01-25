//
//  AchievementManager.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import Combine

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var unlockedAchievements: [Achievement] = []
    
    private let achievementsKey = "SynapseFlow_Achievements"
    
    init() {
        loadAchievements()
        initializeAchievements()
    }
    
    private func initializeAchievements() {
        if achievements.isEmpty {
            achievements = [
                Achievement(title: "Perfect Round", description: "Achieve 100% accuracy in a test", icon: "star.fill"),
                Achievement(title: "Speed Master", description: "Average reaction time under 0.5s", icon: "bolt.fill"),
                Achievement(title: "Marathon Runner", description: "Complete 10 tests", icon: "figure.run"),
                Achievement(title: "Consistency King", description: "Maintain a 7-day streak", icon: "flame.fill"),
                Achievement(title: "Early Bird", description: "Complete 5 morning tests", icon: "sunrise.fill"),
                Achievement(title: "Night Owl", description: "Complete 5 evening tests", icon: "moon.fill"),
                Achievement(title: "High Scorer", description: "Score over 500 points", icon: "trophy.fill"),
                Achievement(title: "Focus Master", description: "Complete test on Hard difficulty", icon: "brain.head.profile")
            ]
            saveAchievements()
        }
    }
    
    func checkAchievements(for metrics: GameMetrics, difficulty: DifficultyLevel, testCount: Int, streak: Int, morningCount: Int, eveningCount: Int) {
        var newUnlocks: [Achievement] = []
        
        // Perfect Round
        if metrics.accuracyPercentage >= 100 && metrics.totalSignals > 0 {
            unlockAchievement(title: "Perfect Round", newUnlocks: &newUnlocks)
        }
        
        // Speed Master
        if metrics.averageReactionTime > 0 && metrics.averageReactionTime < 0.5 {
            unlockAchievement(title: "Speed Master", newUnlocks: &newUnlocks)
        }
        
        // Marathon Runner
        if testCount >= 10 {
            unlockAchievement(title: "Marathon Runner", newUnlocks: &newUnlocks)
        }
        
        // Consistency King
        if streak >= 7 {
            unlockAchievement(title: "Consistency King", newUnlocks: &newUnlocks)
        }
        
        // Early Bird
        if morningCount >= 5 {
            unlockAchievement(title: "Early Bird", newUnlocks: &newUnlocks)
        }
        
        // Night Owl
        if eveningCount >= 5 {
            unlockAchievement(title: "Night Owl", newUnlocks: &newUnlocks)
        }
        
        // High Scorer (need to calculate score from metrics)
        let estimatedScore = metrics.correctTaps * 10 - metrics.incorrectTaps * 5
        if estimatedScore >= 500 {
            unlockAchievement(title: "High Scorer", newUnlocks: &newUnlocks)
        }
        
        // Focus Master
        if difficulty == .hard {
            unlockAchievement(title: "Focus Master", newUnlocks: &newUnlocks)
        }
        
        if !newUnlocks.isEmpty {
            saveAchievements()
        }
    }
    
    private func unlockAchievement(title: String, newUnlocks: inout [Achievement]) {
        if let index = achievements.firstIndex(where: { $0.title == title && !$0.isUnlocked }) {
            achievements[index] = Achievement(
                id: achievements[index].id,
                title: achievements[index].title,
                description: achievements[index].description,
                icon: achievements[index].icon,
                unlockedAt: Date()
            )
            newUnlocks.append(achievements[index])
            unlockedAchievements.append(achievements[index])
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
            unlockedAchievements = achievements.filter { $0.isUnlocked }
        }
    }
}
