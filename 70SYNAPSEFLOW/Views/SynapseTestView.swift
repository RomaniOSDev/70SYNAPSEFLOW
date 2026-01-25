//
//  SynapseTestView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI
import Combine

struct SynapseTestView: View {
    @ObservedObject var dataStore: NeuroDataStore
    @StateObject private var gameEngine = SynapseGameEngine()
    @Environment(\.dismiss) var dismiss
    @State private var showResults = false
    @State private var timeOfDay: TestResult.TimeOfDay = .morning
    @State private var showExitConfirmation = false
    
    var body: some View {
        ZStack {
            GameConstants.backgroundColor
                .ignoresSafeArea()
            
            if !gameEngine.isPlaying && !showResults {
                // Pre-game screen
                preGameView
            } else if gameEngine.isPlaying {
                // Game screen
                gameView
            } else if showResults {
                // Results screen
                resultsView
            }
        }
        .onAppear {
            let hour = Calendar.current.component(.hour, from: Date())
            timeOfDay = hour < 12 ? .morning : .evening
        }
    }
    
    private var preGameView: some View {
        VStack(spacing: 30) {
            Text("SYNAPSE TEST")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Difficulty Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Difficulty")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 12) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Button(action: {
                            dataStore.userSettings.difficulty = level
                        }) {
                            VStack(spacing: 6) {
                                Text(level.displayName)
                                    .font(.system(size: 14, weight: .bold))
                                Text("\(Int(level.gameDuration))s")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(dataStore.userSettings.difficulty == level ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(dataStore.userSettings.difficulty == level ? GameConstants.signalColor : Color.white.opacity(0.1))
                            )
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            VStack(alignment: .leading, spacing: 20) {
                InstructionRow(
                    icon: "circle.fill",
                    color: GameConstants.signalColor,
                    text: "Tap blue neurons (signals) as fast as possible"
                )
                
                InstructionRow(
                    icon: "xmark.circle.fill",
                    color: GameConstants.noiseColor,
                    text: "Avoid green neurons (noise) - they reduce accuracy"
                )
                
                InstructionRow(
                    icon: "clock.fill",
                    color: .white.opacity(0.6),
                    text: "Test duration: \(Int(dataStore.userSettings.difficulty.gameDuration)) seconds"
                )
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            Button(action: {
                SoundManager.shared.soundEnabled = dataStore.userSettings.soundEnabled
                gameEngine.startGame(difficulty: dataStore.userSettings.difficulty)
            }) {
                Text("START TEST")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(GameConstants.signalColor)
                    )
            }
            .padding(.horizontal, 30)
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(30)
    }
    
    private var gameView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background particles effect
                ForEach(gameEngine.neurons) { neuron in
                    Circle()
                        .fill(neuron.type == .signal ? GameConstants.signalColor : GameConstants.noiseColor)
                        .frame(width: neuron.size, height: neuron.size)
                        .position(neuron.position)
                        .opacity(neuron.opacity)
                        .blur(radius: neuron.isAnimating ? 10 : 0)
                }
                
                // UI Overlay
                VStack {
                    // Top bar with exit button
                    HStack {
                        Button(action: {
                            showExitConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Exit")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            gameEngine.stopGame()
                            showResults = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Finish")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(GameConstants.signalColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(GameConstants.signalColor.opacity(0.2))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Timer and Score
                    HStack {
                        VStack(alignment: .leading) {
                            Text("TIME")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(Int(gameEngine.timeRemaining))s")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("SCORE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(gameEngine.score)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(GameConstants.signalColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Instructions
                    VStack(spacing: 8) {
                        HStack(spacing: 20) {
                            Label("Tap", systemImage: "circle.fill")
                                .foregroundColor(GameConstants.signalColor)
                            Label("Avoid", systemImage: "xmark.circle.fill")
                                .foregroundColor(GameConstants.noiseColor)
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                gameEngine.screenSize = geometry.size
            }
            .onChange(of: geometry.size) { newSize in
                gameEngine.screenSize = newSize
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let location = value.location
                        _ = gameEngine.handleTap(at: location)
                    }
            )
            .onChange(of: gameEngine.isPlaying) { isPlaying in
                if !isPlaying {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showResults = true
                    }
                }
            }
            .alert("Exit Test?", isPresented: $showExitConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    gameEngine.stopGame()
                    dismiss()
                }
            } message: {
                Text("Your progress will not be saved if you exit now.")
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            // Top bar with back button
            HStack {
                Button(action: {
                    gameEngine.resetGame()
                    showResults = false
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Text("TEST COMPLETE")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            let metrics = gameEngine.getFinalMetrics()
            let profile = CognitiveAnalytics.analyzeMetrics(metrics)
            
            VStack(spacing: 20) {
                MetricCard(
                    title: "Reaction Speed",
                    value: String(format: "%.2fs", metrics.averageReactionTime),
                    color: GameConstants.signalColor
                )
                
                MetricCard(
                    title: "Accuracy",
                    value: "\(Int(metrics.accuracyPercentage))%",
                    color: GameConstants.noiseColor
                )
                
                MetricCard(
                    title: "Score",
                    value: "\(gameEngine.score)",
                    color: .white
                )
            }
            .padding(.horizontal, 30)
            
            Button(action: {
                let result = TestResult(
                    metrics: metrics,
                    profile: profile,
                    timeOfDay: timeOfDay
                )
                dataStore.saveTestResult(result)
                
                // Generate day plan
                let plan = CognitiveAnalytics.generateDayPlan(from: profile)
                dataStore.saveDayPlan(plan)
                
                // Check for new achievements
                if !dataStore.achievementManager.unlockedAchievements.isEmpty {
                    // Show achievement notification if new ones unlocked
                }
                
                SoundManager.shared.playSound("success")
                dismiss()
            }) {
                Text("SAVE & CONTINUE")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(GameConstants.signalColor)
                    )
            }
            .padding(.horizontal, 30)
            
            Button(action: {
                gameEngine.resetGame()
                showResults = false
            }) {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(30)
    }
}

struct InstructionRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    SynapseTestView(dataStore: NeuroDataStore())
}
