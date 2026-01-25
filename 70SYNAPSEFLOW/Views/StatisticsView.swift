//
//  StatisticsView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI
import UIKit

struct StatisticsView: View {
    @ObservedObject var dataStore: NeuroDataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Overall Stats
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Overall Statistics")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                StatCard(title: "Total Tests", value: "\(dataStore.testHistory.count)", color: GameConstants.signalColor)
                                StatCard(title: "Current Streak", value: "\(dataStore.streak.currentStreak)", color: GameConstants.noiseColor)
                            }
                            
                            HStack(spacing: 15) {
                                StatCard(title: "Longest Streak", value: "\(dataStore.streak.longestStreak)", color: .white)
                                StatCard(title: "Achievements", value: "\(dataStore.achievementManager.unlockedAchievements.count)/\(dataStore.achievementManager.achievements.count)", color: GameConstants.signalColor)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Progress Chart
                        if !dataStore.testHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Progress Over Time")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                ProgressChartView(dataPoints: dataStore.getWeeklyCognitiveForm())
                                    .frame(height: 200)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        
                        // Best Results
                        if !dataStore.bestResults.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Best Results")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                ForEach(dataStore.bestResults.prefix(5)) { result in
                                    BestResultRow(result: result)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        
                        // Export Button
                        Button(action: {
                            shareResults()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Data")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(GameConstants.signalColor)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func shareResults() {
        let csv = ExportManager.shared.exportToCSV(testHistory: dataStore.testHistory)
        let activityVC = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ProgressChartView: View {
    let dataPoints: [CognitiveDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(dataPoints) { point in
                    VStack {
                        HStack(alignment: .bottom, spacing: 4) {
                            Rectangle()
                                .fill(GameConstants.signalColor)
                                .frame(width: 20, height: CGFloat(point.morningSpeed) * geometry.size.height * 0.8)
                            
                            Rectangle()
                                .fill(GameConstants.noiseColor)
                                .frame(width: 20, height: CGFloat(point.eveningSpeed) * geometry.size.height * 0.8)
                        }
                        
                        Text(dayAbbreviation(for: point.date))
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct BestResultRow: View {
    let result: TestResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.timestamp, style: .date)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(result.timeOfDay.rawValue.capitalized)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(result.profile.accuracy * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(GameConstants.signalColor)
                    Text("Accuracy")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.2fs", result.metrics.averageReactionTime))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(GameConstants.noiseColor)
                    Text("Speed")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
        )
    }
}

#Preview {
    StatisticsView(dataStore: NeuroDataStore())
}
