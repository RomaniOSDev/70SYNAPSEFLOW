//
//  ContentView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = NeuroDataStore()
    @State private var showSynapseTest = false
    @State private var showFlowBuilder = false
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showStats = false
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // App Title
                    VStack(spacing: 10) {
                        Text("SYNAPSE FLOW")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Neuro-Planner")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Mode Selection
                    VStack(spacing: 20) {
                        // Synapse Test Button
                        Button(action: {
                            showSynapseTest = true
                        }) {
                            ModeCard(
                                title: "SYNAPSE TEST",
                                subtitle: "Measure your focus",
                                icon: "brain.head.profile",
                                color: GameConstants.signalColor
                            )
                        }
                        
                        // Flow Builder Button
                        Button(action: {
                            showFlowBuilder = true
                        }) {
                            ModeCard(
                                title: "FLOW BUILDER",
                                subtitle: "Build your day",
                                icon: "network",
                                color: GameConstants.noiseColor
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Stats and Streak
                    HStack(spacing: 20) {
                        // Streak
                        VStack(spacing: 4) {
                            Text("\(dataStore.streak.currentStreak)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(GameConstants.signalColor)
                            Text("Day Streak")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // Achievements
                        Button(action: {
                            showAchievements = true
                        }) {
                            VStack(spacing: 4) {
                                Text("\(dataStore.achievementManager.unlockedAchievements.count)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(GameConstants.noiseColor)
                                Text("Achievements")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Recent Activity
                    if !dataStore.testHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recent Activity")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            let lastTest = dataStore.testHistory.last!
                            HStack {
                                Text("Last test: \(lastTest.timestamp, style: .relative)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Spacer()
                                
                                Text("Accuracy: \(Int(lastTest.profile.accuracy * 100))%")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(GameConstants.signalColor)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 10)
                    }
                    
                    // Bottom buttons
                    HStack(spacing: 15) {
                        Button(action: {
                            showStats = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        
                        Spacer()
                        
                        // Motivational quote
                        let quote = MotivationalQuote.random()
                        VStack(spacing: 4) {
                            Text(quote.text)
                                .font(.system(size: 11))
                                .italic()
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            if let author = quote.author {
                                Text("— \(author)")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .frame(maxWidth: 150)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showSynapseTest) {
                SynapseTestView(dataStore: dataStore)
            }
            .sheet(isPresented: $showFlowBuilder) {
                FlowBuilderView(dataStore: dataStore)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(dataStore: dataStore)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(achievementManager: dataStore.achievementManager)
            }
            .sheet(isPresented: $showStats) {
                StatisticsView(dataStore: dataStore)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(isPresented: $showOnboarding)
            }
            .onAppear {
                checkOnboardingStatus()
            }
        }
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            showOnboarding = true
        }
    }
}

struct ModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ContentView()
}
