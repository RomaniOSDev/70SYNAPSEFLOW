//
//  NotificationManager.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleTestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Synapse Flow"
        content.body = "Time for your daily cognitive test!"
        content.sound = .default
        
        // Schedule for 8 AM and 8 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let morningRequest = UNNotificationRequest(identifier: "morningTest", content: content, trigger: morningTrigger)
        
        dateComponents.hour = 20
        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let eveningRequest = UNNotificationRequest(identifier: "eveningTest", content: content, trigger: eveningTrigger)
        
        UNUserNotificationCenter.current().add(morningRequest)
        UNUserNotificationCenter.current().add(eveningRequest)
    }
    
    func scheduleFocusBlockReminder(for node: FlowNode) {
        guard node.type == .task else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Block Starting"
        content.body = "Time to focus on: \(node.title)"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: node.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: node.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleBreakReminder(for node: FlowNode) {
        guard node.type == .rest else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Break Time"
        content.body = "Time to take a break and recharge"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: node.startTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: node.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func schedulePlanNotifications(for plan: DayPlan) {
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new ones
        for node in plan.nodes {
            if node.type == .task {
                scheduleFocusBlockReminder(for: node)
            } else {
                scheduleBreakReminder(for: node)
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
