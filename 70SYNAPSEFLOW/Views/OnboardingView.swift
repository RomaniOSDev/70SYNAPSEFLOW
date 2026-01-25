//
//  OnboardingView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            GameConstants.backgroundColor
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    title: "Welcome to Synapse Flow",
                    description: "Measure your cognitive performance and build your perfect day based on your focus levels.",
                    icon: "brain.head.profile",
                    color: GameConstants.signalColor,
                    pageIndex: 0
                )
                .tag(0)
                
                OnboardingPage(
                    title: "Synapse Test",
                    description: "Tap blue neurons quickly, avoid green ones. Complete the 60-second test to analyze your cognitive state.",
                    icon: "circle.grid.2x2.fill",
                    color: GameConstants.noiseColor,
                    pageIndex: 1
                )
                .tag(1)
                
                OnboardingPage(
                    title: "Flow Builder",
                    description: "Get a personalized day plan based on your test results. Edit and customize your schedule.",
                    icon: "network",
                    color: GameConstants.signalColor,
                    pageIndex: 2
                )
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                if currentPage == 2 {
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        isPresented = false
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(GameConstants.signalColor)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(GameConstants.signalColor)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(30)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
