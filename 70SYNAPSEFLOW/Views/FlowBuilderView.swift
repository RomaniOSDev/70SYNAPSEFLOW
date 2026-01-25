//
//  FlowBuilderView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI

struct FlowBuilderView: View {
    @ObservedObject var dataStore: NeuroDataStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedNode: UUID?
    @State private var isEditing = false
    @State private var showingRecommendations = false
    @State private var showingEditNode = false
    @State private var editingNode: FlowNode?
    @State private var showingNodeDetails = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                if let plan = dataStore.currentPlan, !plan.nodes.isEmpty {
                    flowBuilderContent(plan: plan)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("FLOW BUILDER")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if let plan = dataStore.currentPlan, !plan.nodes.isEmpty {
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Image(systemName: isEditing ? "checkmark" : "pencil")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        showingRecommendations.toggle()
                    }) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingRecommendations) {
                RecommendationsView(dataStore: dataStore)
            }
            .sheet(item: $editingNode) { node in
                EditNodeView(node: node, dataStore: dataStore)
            }
            .sheet(isPresented: $showingNodeDetails) {
                if let plan = dataStore.currentPlan,
                   let nodeId = selectedNode,
                   let node = plan.nodes.first(where: { $0.id == nodeId }) {
                    NodeDetailsView(node: node, onEdit: {
                        showingNodeDetails = false
                        editingNode = node
                        showingEditNode = true
                    })
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No Day Plan")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Complete a Synapse Test to generate your personalized day plan")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                dismiss()
                // Note: User will need to go back to main screen and tap Synapse Test
            }) {
                Text("Take Test")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(GameConstants.signalColor)
                    )
            }
        }
    }
    
    private func flowBuilderContent(plan: DayPlan) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Conductivity Score
                VStack(spacing: 10) {
                    Text("Day Conductivity")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(Int(plan.conductivity))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(GameConstants.signalColor)
                    
                    Text(plan.template == .peakPerformance ? "Peak Performance" :
                         plan.template == .recovery ? "Recovery Mode" : "Balanced")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Timeline
                VStack(spacing: 15) {
                    ForEach(Array(plan.nodes.enumerated()), id: \.element.id) { index, node in
                        NodeView(
                            node: node,
                            isSelected: selectedNode == node.id,
                            index: index,
                            totalNodes: plan.nodes.count,
                            isEditing: isEditing
                        )
                        .onTapGesture {
                            if isEditing {
                                editingNode = node
                                showingEditNode = true
                            } else {
                                selectedNode = node.id
                                showingNodeDetails = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct NodeView: View {
    let node: FlowNode
    let isSelected: Bool
    let index: Int
    let totalNodes: Int
    let isEditing: Bool
    
    @State private var pulseAnimation = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Connection line
            if index < totalNodes - 1 {
                VStack {
                    Circle()
                        .fill(node.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(node.color.opacity(0.5), lineWidth: 2)
                                .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                                .opacity(pulseAnimation ? 0 : 1)
                        )
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                pulseAnimation = true
                            }
                        }
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [node.color.opacity(0.6), node.color.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2)
                        .frame(height: 40)
                }
                .frame(width: 20)
            } else {
                Circle()
                    .fill(node.color)
                    .frame(width: 12, height: 12)
                    .frame(width: 20)
            }
            
            // Node content
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(node.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(formatDuration(node.duration))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(formatTime(node.startTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if let category = node.category {
                        Image(systemName: category.icon)
                            .font(.system(size: 16))
                            .foregroundColor(category.color)
                    }
                    
                    Image(systemName: node.type == .task ? "brain.head.profile" : "pause.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(node.color)
                    
                    if isEditing {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? node.color : (isEditing ? Color.white.opacity(0.3) : Color.clear), lineWidth: 2)
                    )
            )
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct RecommendationsView: View {
    @ObservedObject var dataStore: NeuroDataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Cognitive Insights")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        let recommendations = dataStore.getRecommendations()
                        if recommendations.isEmpty {
                            Text("Complete more tests to get personalized recommendations")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 20)
                        } else {
                            ForEach(recommendations, id: \.self) { recommendation in
                                RecommendationCard(text: recommendation)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Weekly Chart
                        if !dataStore.testHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Weekly Cognitive Form")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                WeeklyChartView(dataPoints: dataStore.getWeeklyCognitiveForm())
                                    .padding(.horizontal, 20)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Recommendations")
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
}

struct RecommendationCard: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(GameConstants.signalColor)
                .font(.system(size: 20))
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct WeeklyChartView: View {
    let dataPoints: [CognitiveDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if !dataPoints.isEmpty {
                GeometryReader { geometry in
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(dataPoints) { point in
                            VStack(spacing: 8) {
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
                .frame(height: 150)
                
                HStack {
                    LegendItem(color: GameConstants.signalColor, label: "Morning")
                    Spacer()
                    LegendItem(color: GameConstants.noiseColor, label: "Evening")
                }
                .padding(.top, 10)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    FlowBuilderView(dataStore: NeuroDataStore())
}
