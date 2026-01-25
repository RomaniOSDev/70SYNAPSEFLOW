//
//  GameModels.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import SwiftUI

// MARK: - Neuron Types
enum NeuronType {
    case signal    // Blue (#1475E1) - tap to accept
    case noise     // Green (#16FF16) - avoid tapping
}

// MARK: - Neuron Model
struct Neuron: Identifiable {
    let id = UUID()
    let type: NeuronType
    var position: CGPoint
    var size: CGFloat
    var opacity: Double = 1.0
    var isAnimating: Bool = false
    var spawnTime: Date = Date()
    var velocity: CGPoint = CGPoint(x: 0, y: 2)
}

// MARK: - Game Metrics
struct GameMetrics {
    var reactionTime: [TimeInterval] = []
    var accuracy: Int = 0
    var errors: Int = 0
    var totalSignals: Int = 0
    var totalNoise: Int = 0
    var correctTaps: Int = 0
    var incorrectTaps: Int = 0
    var timeStamps: [Date] = []
    
    var averageReactionTime: TimeInterval {
        guard !reactionTime.isEmpty else { return 0 }
        return reactionTime.reduce(0, +) / Double(reactionTime.count)
    }
    
    var accuracyPercentage: Double {
        guard totalSignals > 0 else { return 0 }
        return Double(correctTaps) / Double(totalSignals) * 100
    }
    
    var errorRate: Double {
        let total = correctTaps + incorrectTaps
        guard total > 0 else { return 0 }
        return Double(incorrectTaps) / Double(total) * 100
    }
}

// MARK: - Cognitive Profile
struct CognitiveProfile: Codable {
    var speed: Double          // Average reaction time
    var accuracy: Double       // Percentage of correct taps
    var fatigue: Double        // How performance degrades over time
    var attentionPattern: Double  // Consistency of performance
    
    var templateType: DayTemplate {
        if speed > 0.8 && accuracy > 0.7 {
            return .peakPerformance
        } else if speed < 0.4 || accuracy < 0.5 {
            return .recovery
        } else {
            return .balanced
        }
    }
}

// MARK: - Day Template
enum DayTemplate: Codable {
    case recovery          // Low speed + many errors
    case balanced          // Medium performance
    case peakPerformance   // High speed + stable
    
    var focusBlockDuration: TimeInterval {
        switch self {
        case .recovery: return 15 * 60      // 15 minutes
        case .balanced: return 30 * 60      // 30 minutes
        case .peakPerformance: return 45 * 60  // 45 minutes
        }
    }
    
    var breakDuration: TimeInterval {
        switch self {
        case .recovery: return 10 * 60      // 10 minutes
        case .balanced: return 5 * 60       // 5 minutes
        case .peakPerformance: return 3 * 60   // 3 minutes
        }
    }
    
    var breakFrequency: Int {
        switch self {
        case .recovery: return 2      // Break after every 2 blocks
        case .balanced: return 3      // Break after every 3 blocks
        case .peakPerformance: return 4  // Break after every 4 blocks
        }
    }
}

// MARK: - Flow Node
struct FlowNode: Identifiable {
    let id = UUID()
    var type: NodeType
    var title: String
    var duration: TimeInterval
    var startTime: Date
    var position: CGPoint = .zero
    var connections: [UUID] = []
    var category: TaskCategory? = nil
    
    enum NodeType {
        case task    // Blue node
        case rest    // Green node
    }
    
    var color: Color {
        if let category = category, type == .task {
            return category.color
        }
        switch type {
        case .task: return Color(red: 0.08, green: 0.46, blue: 0.88)  // #1475E1
        case .rest: return Color(red: 0.09, green: 1.0, blue: 0.09)   // #16FF16
        }
    }
}

// MARK: - Day Plan
struct DayPlan: Identifiable {
    let id: UUID
    var nodes: [FlowNode] = []
    var createdAt: Date = Date()
    var template: DayTemplate
    var conductivity: Double = 0.0  // Overall efficiency score
    
    init(id: UUID = UUID(), nodes: [FlowNode] = [], createdAt: Date = Date(), template: DayTemplate, conductivity: Double = 0.0) {
        self.id = id
        self.nodes = nodes
        self.createdAt = createdAt
        self.template = template
        self.conductivity = conductivity
    }
    
    mutating func calculateConductivity() {
        guard !nodes.isEmpty else {
            conductivity = 0
            return
        }
        
        let taskNodes = nodes.filter { $0.type == .task }
        let breakNodes = nodes.filter { $0.type == .rest }
        let totalDuration = nodes.reduce(0) { $0 + $1.duration }
        
        let taskRatio = Double(taskNodes.count) / Double(nodes.count)
        let connectivity = Double(nodes.reduce(0) { $0 + $1.connections.count }) / Double(nodes.count * 2)
        
        conductivity = (taskRatio * 0.6 + connectivity * 0.4) * 100
    }
}

// MARK: - Test Result
struct TestResult: Identifiable, Codable {
    let id = UUID()
    var metrics: GameMetrics
    var profile: CognitiveProfile
    var timestamp: Date = Date()
    var timeOfDay: TimeOfDay
    
    enum TimeOfDay: String, Codable {
        case morning
        case evening
    }
}

// MARK: - Constants
struct GameConstants {
    static let gameDuration: TimeInterval = 60.0
    static let signalColor = Color(red: 0.08, green: 0.46, blue: 0.88)  // #1475E1
    static let noiseColor = Color(red: 0.09, green: 1.0, blue: 0.09)    // #16FF16
    static let backgroundColor = Color(red: 0.10, green: 0.17, blue: 0.22)  // #1A2C38
    static let minNeuronSize: CGFloat = 40
    static let maxNeuronSize: CGFloat = 80
    static let spawnInterval: TimeInterval = 1.5
    static let neuronLifetime: TimeInterval = 8.0
}
