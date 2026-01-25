//
//  EditNodeView.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import SwiftUI

struct EditNodeView: View {
    @State var node: FlowNode
    @ObservedObject var dataStore: NeuroDataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var duration: Double
    @State private var selectedCategory: TaskCategory?
    
    init(node: FlowNode, dataStore: NeuroDataStore) {
        self.node = node
        self.dataStore = dataStore
        _title = State(initialValue: node.title)
        _duration = State(initialValue: node.duration / 60.0) // Convert to minutes
        _selectedCategory = State(initialValue: node.category)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GameConstants.backgroundColor
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Task Details").foregroundColor(.white)) {
                        TextField("Title", text: $title)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration: \(Int(duration)) minutes")
                                .foregroundColor(.white)
                            Slider(value: $duration, in: 5...120, step: 5)
                                .tint(GameConstants.signalColor)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                    
                    if node.type == .task {
                        Section(header: Text("Category").foregroundColor(.white)) {
                            Picker("Category", selection: $selectedCategory) {
                                Text("None").tag(nil as TaskCategory?)
                                ForEach(TaskCategory.allCases.filter { $0 != .rest }, id: \.self) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.displayName)
                                    }
                                    .tag(category as TaskCategory?)
                                }
                            }
                            .foregroundColor(.white)
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Node")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNode()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func saveNode() {
        guard var plan = dataStore.currentPlan,
              let index = plan.nodes.firstIndex(where: { $0.id == node.id }) else {
            dismiss()
            return
        }
        
        plan.nodes[index].title = title
        plan.nodes[index].duration = duration * 60.0 // Convert back to seconds
        plan.nodes[index].category = selectedCategory
        plan.calculateConductivity()
        
        dataStore.currentPlan = plan
        dataStore.saveDayPlan(plan)
        
        // Update notifications if enabled
        if dataStore.userSettings.notificationsEnabled {
            NotificationManager.shared.schedulePlanNotifications(for: plan)
        }
        
        dismiss()
    }
}

#Preview {
    EditNodeView(node: FlowNode(type: .task, title: "Test", duration: 1800, startTime: Date()), dataStore: NeuroDataStore())
}
