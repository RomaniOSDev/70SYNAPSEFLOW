//
//  NodeDetailsView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI

struct NodeDetailsView: View {
    let node: FlowNode
    let onEdit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Node Icon
                        ZStack {
                            Circle()
                                .fill(node.color.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            if let category = node.category {
                                Image(systemName: category.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(category.color)
                            } else {
                                Image(systemName: node.type == .task ? "brain.head.profile" : "pause.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(node.color)
                            }
                        }
                        .padding(.top, 30)
                        
                        // Node Title
                        Text(node.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Node Type Badge
                        HStack(spacing: 8) {
                            Circle()
                                .fill(node.color)
                                .frame(width: 12, height: 12)
                            
                            Text(node.type == .task ? "Focus Block" : "Break")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(node.color)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(node.color.opacity(0.2))
                        )
                        
                        // Details
                        VStack(spacing: 20) {
                            DetailRow(
                                icon: "clock.fill",
                                title: "Duration",
                                value: formatDuration(node.duration),
                                color: .white
                            )
                            
                            DetailRow(
                                icon: "calendar",
                                title: "Start Time",
                                value: formatTime(node.startTime),
                                color: .white
                            )
                            
                            if let category = node.category {
                                DetailRow(
                                    icon: category.icon,
                                    title: "Category",
                                    value: category.displayName,
                                    color: category.color
                                )
                            }
                            
                            if !node.connections.isEmpty {
                                DetailRow(
                                    icon: "link",
                                    title: "Connections",
                                    value: "\(node.connections.count)",
                                    color: GameConstants.signalColor
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)
                        
                        // Edit Button
                        Button(action: {
                            onEdit()
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Node")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(GameConstants.signalColor)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Node Details")
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NodeDetailsView(
        node: FlowNode(
            type: .task,
            title: "Work Block 1",
            duration: 1800,
            startTime: Date(),
            category: .work
        ),
        onEdit: {}
    )
}
