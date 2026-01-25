//
//  CognitiveAnalytics.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation

class CognitiveAnalytics {
    
    static func analyzeMetrics(_ metrics: GameMetrics) -> CognitiveProfile {
        // Normalize speed (lower reaction time = higher speed)
        let avgReaction = metrics.averageReactionTime
        let normalizedSpeed = max(0, min(1, 1.0 - (avgReaction / 2.0))) // 2 seconds = 0 speed
        
        // Accuracy as percentage (0-1)
        let normalizedAccuracy = metrics.accuracyPercentage / 100.0
        
        // Calculate fatigue (how performance degrades)
        let fatigue = calculateFatigue(metrics)
        
        // Calculate attention pattern (consistency)
        let attentionPattern = calculateAttentionPattern(metrics)
        
        return CognitiveProfile(
            speed: normalizedSpeed,
            accuracy: normalizedAccuracy,
            fatigue: fatigue,
            attentionPattern: attentionPattern
        )
    }
    
    private static func calculateFatigue(_ metrics: GameMetrics) -> Double {
        guard metrics.reactionTime.count > 2 else { return 0.5 }
        
        let firstHalf = Array(metrics.reactionTime.prefix(metrics.reactionTime.count / 2))
        let secondHalf = Array(metrics.reactionTime.suffix(metrics.reactionTime.count / 2))
        
        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        // If second half is slower, fatigue is higher
        let fatigueRatio = (secondAvg - firstAvg) / max(firstAvg, 0.1)
        return max(0, min(1, (fatigueRatio + 1) / 2))
    }
    
    private static func calculateAttentionPattern(_ metrics: GameMetrics) -> Double {
        guard metrics.reactionTime.count > 1 else { return 0.5 }
        
        // Calculate standard deviation
        let avg = metrics.averageReactionTime
        let variance = metrics.reactionTime.map { pow($0 - avg, 2) }.reduce(0, +) / Double(metrics.reactionTime.count)
        let stdDev = sqrt(variance)
        
        // Lower std dev = more consistent = higher attention pattern
        let normalized = max(0, min(1, 1.0 - (stdDev / avg)))
        return normalized
    }
    
    static func generateDayPlan(from profile: CognitiveProfile) -> DayPlan {
        let template = profile.templateType
        var plan = DayPlan(template: template)
        
        let startHour = 8 // 8 AM
        let endHour = 22  // 10 PM
        var currentTime = Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: Date()) ?? Date()
        
        var nodeIndex = 0
        var blocksSinceBreak = 0
        
        while Calendar.current.component(.hour, from: currentTime) < endHour {
            if blocksSinceBreak >= template.breakFrequency {
                // Add rest node
                let restNode = FlowNode(
                    type: .rest,
                    title: "Break",
                    duration: template.breakDuration,
                    startTime: currentTime
                )
                plan.nodes.append(restNode)
                currentTime = currentTime.addingTimeInterval(template.breakDuration)
                blocksSinceBreak = 0
            } else {
                // Add task node with category rotation
                let categories: [TaskCategory] = [.work, .study, .creative, .exercise]
                let category = categories[nodeIndex % categories.count]
                
                let taskNode = FlowNode(
                    type: .task,
                    title: "\(category.displayName) Block \(nodeIndex + 1)",
                    duration: template.focusBlockDuration,
                    startTime: currentTime,
                    category: category
                )
                plan.nodes.append(taskNode)
                currentTime = currentTime.addingTimeInterval(template.focusBlockDuration)
                blocksSinceBreak += 1
                nodeIndex += 1
            }
        }
        
        // Connect nodes
        for i in 0..<plan.nodes.count - 1 {
            plan.nodes[i].connections.append(plan.nodes[i + 1].id)
        }
        
        plan.calculateConductivity()
        return plan
    }
}
