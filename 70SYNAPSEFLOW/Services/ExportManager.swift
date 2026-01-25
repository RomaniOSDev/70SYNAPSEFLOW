//
//  ExportManager.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    func exportToCSV(testHistory: [TestResult]) -> String {
        var csv = "Date,Time of Day,Reaction Speed,Accuracy,Fatigue,Attention Pattern\n"
        
        for result in testHistory {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            csv += "\(dateFormatter.string(from: result.timestamp)),"
            csv += "\(result.timeOfDay.rawValue),"
            csv += "\(result.metrics.averageReactionTime),"
            csv += "\(result.profile.accuracy),"
            csv += "\(result.profile.fatigue),"
            csv += "\(result.profile.attentionPattern)\n"
        }
        
        return csv
    }
    
    func exportToJSON(testHistory: [TestResult]) -> Data? {
        return try? JSONEncoder().encode(testHistory)
    }
    
    func shareResults(_ results: [TestResult]) -> [Any] {
        let csv = exportToCSV(testHistory: results)
        return [csv]
    }
}
