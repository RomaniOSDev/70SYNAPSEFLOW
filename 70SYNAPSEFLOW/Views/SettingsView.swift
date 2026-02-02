//
//  SettingsView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject var dataStore: NeuroDataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Game Settings").foregroundColor(.white)) {
                        Picker("Difficulty", selection: $dataStore.userSettings.difficulty) {
                            ForEach(DifficultyLevel.allCases, id: \.self) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Toggle("Sound Effects", isOn: $dataStore.userSettings.soundEnabled)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    Section(header: Text("Notifications").foregroundColor(.white)) {
                        Toggle("Enable Notifications", isOn: $dataStore.userSettings.notificationsEnabled)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    Section(header: Text("Statistics").foregroundColor(.white)) {
                        HStack {
                            Text("Current Streak")
                            Spacer()
                            Text("\(dataStore.streak.currentStreak) days")
                                .foregroundColor(GameConstants.signalColor)
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Text("Longest Streak")
                            Spacer()
                            Text("\(dataStore.streak.longestStreak) days")
                                .foregroundColor(GameConstants.signalColor)
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Text("Total Tests")
                            Spacer()
                            Text("\(dataStore.testHistory.count)")
                                .foregroundColor(GameConstants.signalColor)
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    Section(header: Text("About").foregroundColor(.white)) {
                        Button(action: {
                            rateApp()
                        }) {
                            HStack {
                                Text("Rate Us")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                        
                        Button(action: {
                            openURL("https://www.termsfeed.com/live/859b1641-e1f1-44a7-96d6-b586b7e42bf3")
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                        
                        Button(action: {
                            openURL("https://www.termsfeed.com/live/85e83116-c139-45e0-b750-7be26bdce636")
                        }) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 12))
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: dataStore.userSettings.soundEnabled) { _ in
                SoundManager.shared.soundEnabled = dataStore.userSettings.soundEnabled
                dataStore.saveData()
            }
            .onChange(of: dataStore.userSettings.difficulty) { _ in
                dataStore.saveData()
            }
            .onChange(of: dataStore.userSettings.notificationsEnabled) { enabled in
                if enabled {
                    NotificationManager.shared.requestAuthorization()
                    NotificationManager.shared.scheduleTestReminder()
                } else {
                    NotificationManager.shared.cancelAllNotifications()
                }
                dataStore.saveData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dataStore.saveData()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView(dataStore: NeuroDataStore())
}
