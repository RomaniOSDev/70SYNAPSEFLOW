//
//  NeuroDataStore.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import SwiftUI
import Combine

class NeuroDataStore: ObservableObject {
    @Published var testHistory: [TestResult] = []
    @Published var dayPlans: [DayPlan] = []
    @Published var currentPlan: DayPlan?
    @Published var streak = Streak()
    @Published var userSettings = UserSettings()
    @Published var bestResults: [TestResult] = []
    
    let achievementManager = AchievementManager()
    
    private let testHistoryKey = "SynapseFlow_TestHistory"
    private let dayPlansKey = "SynapseFlow_DayPlans"
    private let currentPlanKey = "SynapseFlow_CurrentPlan"
    private let streakKey = "SynapseFlow_Streak"
    private let settingsKey = "SynapseFlow_Settings"
    private let bestResultsKey = "SynapseFlow_BestResults"
    
    init() {
        loadData()
        updateBestResults()
    }
    
    func saveTestResult(_ result: TestResult) {
        testHistory.append(result)
        streak.updateStreak()
        updateBestResults()
        
        // Check achievements
        let morningCount = testHistory.filter { $0.timeOfDay == .morning }.count
        let eveningCount = testHistory.filter { $0.timeOfDay == .evening }.count
        achievementManager.checkAchievements(
            for: result.metrics,
            difficulty: userSettings.difficulty,
            testCount: testHistory.count,
            streak: streak.currentStreak,
            morningCount: morningCount,
            eveningCount: eveningCount
        )
        
        saveData()
    }
    
    func updateBestResults() {
        // Best accuracy
        if let bestAccuracy = testHistory.max(by: { $0.metrics.accuracyPercentage < $1.metrics.accuracyPercentage }) {
            if !bestResults.contains(where: { $0.id == bestAccuracy.id }) {
                bestResults.append(bestAccuracy)
            }
        }
        
        // Best speed
        if let bestSpeed = testHistory.filter({ $0.metrics.averageReactionTime > 0 })
            .min(by: { $0.metrics.averageReactionTime > $1.metrics.averageReactionTime }) {
            if !bestResults.contains(where: { $0.id == bestSpeed.id }) {
                bestResults.append(bestSpeed)
            }
        }
        
        bestResults = Array(bestResults.prefix(10)) // Keep top 10
    }
    
    func saveDayPlan(_ plan: DayPlan) {
        dayPlans.append(plan)
        currentPlan = plan
        saveData()
    }
    
    func getWeeklyCognitiveForm() -> [CognitiveDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let recentTests = testHistory.filter { $0.timestamp >= weekAgo }
        
        var dataPoints: [CognitiveDataPoint] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayTests = recentTests.filter { test in
                test.timestamp >= dayStart && test.timestamp < dayEnd
            }
            
            let morningTest = dayTests.first { $0.timeOfDay == .morning }
            let eveningTest = dayTests.first { $0.timeOfDay == .evening }
            
            let morningSpeed = morningTest?.profile.speed ?? 0
            let eveningSpeed = eveningTest?.profile.speed ?? 0
            
            dataPoints.append(CognitiveDataPoint(
                date: date,
                morningSpeed: morningSpeed,
                eveningSpeed: eveningSpeed
            ))
        }
        
        return dataPoints.reversed()
    }
    
    func getRecommendations() -> [String] {
        var recommendations: [String] = []
        
        let morningTests = testHistory.filter { $0.timeOfDay == .morning }
        let eveningTests = testHistory.filter { $0.timeOfDay == .evening }
        
        guard !morningTests.isEmpty && !eveningTests.isEmpty else {
            return ["Complete more tests to get personalized recommendations"]
        }
        
        let avgMorningSpeed = morningTests.map { $0.profile.speed }.reduce(0, +) / Double(morningTests.count)
        let avgEveningSpeed = eveningTests.map { $0.profile.speed }.reduce(0, +) / Double(eveningTests.count)
        
        let speedDifference = ((avgMorningSpeed - avgEveningSpeed) / avgMorningSpeed) * 100
        
        if speedDifference > 15 {
            recommendations.append("Your reaction speed in the morning is \(Int(speedDifference))% higher than in the evening. Schedule complex tasks before 12:00 PM.")
        } else if speedDifference < -15 {
            recommendations.append("Your reaction speed in the evening is \(Int(abs(speedDifference)))% higher than in the morning. Consider scheduling important tasks in the afternoon.")
        }
        
        let avgAccuracy = testHistory.map { $0.profile.accuracy }.reduce(0, +) / Double(testHistory.count)
        if avgAccuracy < 0.6 {
            recommendations.append("Your accuracy is below optimal. Consider taking more breaks between focus sessions.")
        }
        
        return recommendations
    }
    
    func saveData() {
        // Save test history
        if let encoded = try? JSONEncoder().encode(testHistory) {
            UserDefaults.standard.set(encoded, forKey: testHistoryKey)
        }
        
        // Save day plans
        if let encoded = try? JSONEncoder().encode(dayPlans) {
            UserDefaults.standard.set(encoded, forKey: dayPlansKey)
        }
        
        // Save current plan
        if let plan = currentPlan, let encoded = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(encoded, forKey: currentPlanKey)
        }
        
        // Save streak
        if let encoded = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }
        
        // Save settings
        if let encoded = try? JSONEncoder().encode(userSettings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
        
        // Save best results
        if let encoded = try? JSONEncoder().encode(bestResults) {
            UserDefaults.standard.set(encoded, forKey: bestResultsKey)
        }
    }
    
    private func loadData() {
        // Load test history
        if let data = UserDefaults.standard.data(forKey: testHistoryKey),
           let decoded = try? JSONDecoder().decode([TestResult].self, from: data) {
            testHistory = decoded
        }
        
        // Load day plans
        if let data = UserDefaults.standard.data(forKey: dayPlansKey),
           let decoded = try? JSONDecoder().decode([DayPlan].self, from: data) {
            dayPlans = decoded
        }
        
        // Load current plan
        if let data = UserDefaults.standard.data(forKey: currentPlanKey),
           let decoded = try? JSONDecoder().decode(DayPlan.self, from: data) {
            currentPlan = decoded
        }
        
        // Load streak
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let decoded = try? JSONDecoder().decode(Streak.self, from: data) {
            streak = decoded
        }
        
        // Load settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(UserSettings.self, from: data) {
            userSettings = decoded
        }
        
        // Load best results
        if let data = UserDefaults.standard.data(forKey: bestResultsKey),
           let decoded = try? JSONDecoder().decode([TestResult].self, from: data) {
            bestResults = decoded
        }
    }
}

// MARK: - Supporting Types
struct CognitiveDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let morningSpeed: Double
    let eveningSpeed: Double
}

// MARK: - Codable Extensions
extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
}

extension GameMetrics: Codable {
    enum CodingKeys: String, CodingKey {
        case reactionTime, accuracy, errors, totalSignals, totalNoise, correctTaps, incorrectTaps, timeStamps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reactionTime = try container.decode([TimeInterval].self, forKey: .reactionTime)
        accuracy = try container.decode(Int.self, forKey: .accuracy)
        errors = try container.decode(Int.self, forKey: .errors)
        totalSignals = try container.decode(Int.self, forKey: .totalSignals)
        totalNoise = try container.decode(Int.self, forKey: .totalNoise)
        correctTaps = try container.decode(Int.self, forKey: .correctTaps)
        incorrectTaps = try container.decode(Int.self, forKey: .incorrectTaps)
        timeStamps = try container.decode([Date].self, forKey: .timeStamps)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reactionTime, forKey: .reactionTime)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encode(errors, forKey: .errors)
        try container.encode(totalSignals, forKey: .totalSignals)
        try container.encode(totalNoise, forKey: .totalNoise)
        try container.encode(correctTaps, forKey: .correctTaps)
        try container.encode(incorrectTaps, forKey: .incorrectTaps)
        try container.encode(timeStamps, forKey: .timeStamps)
    }
}


extension FlowNode: Codable {
    enum CodingKeys: String, CodingKey {
        case id, type, title, duration, startTime, position, connections, category
    }
    
    enum NodeTypeCoding: String, Codable {
        case task, rest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(NodeTypeCoding.self, forKey: .type)
        type = typeString == .task ? .task : .rest
        title = try container.decode(String.self, forKey: .title)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        startTime = try container.decode(Date.self, forKey: .startTime)
        position = try container.decode(CGPoint.self, forKey: .position)
        connections = try container.decode([UUID].self, forKey: .connections)
        category = try container.decodeIfPresent(TaskCategory.self, forKey: .category)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type == .task ? NodeTypeCoding.task : NodeTypeCoding.rest, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(duration, forKey: .duration)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(position, forKey: .position)
        try container.encode(connections, forKey: .connections)
        try container.encodeIfPresent(category, forKey: .category)
    }
}

extension DayPlan: Codable {
    enum CodingKeys: String, CodingKey {
        case id, nodes, createdAt, template, conductivity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let nodes = try container.decode([FlowNode].self, forKey: .nodes)
        let createdAt = try container.decode(Date.self, forKey: .createdAt)
        let template = try container.decode(DayTemplate.self, forKey: .template)
        let conductivity = try container.decode(Double.self, forKey: .conductivity)
        
        self.init(id: id, nodes: nodes, createdAt: createdAt, template: template, conductivity: conductivity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(template, forKey: .template)
        try container.encode(conductivity, forKey: .conductivity)
    }
}
