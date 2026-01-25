//
//  SoundManager.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import AVFoundation
import AudioToolbox
import SwiftUI
import Combine

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var soundEnabled: Bool = true
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playSound(_ soundName: String) {
        guard soundEnabled else { return }
        
        if let player = audioPlayers[soundName] {
            player.currentTime = 0
            player.play()
        } else {
            // Create system sound for simple feedback
            let systemSoundID: SystemSoundID
            switch soundName {
            case "tap":
                systemSoundID = 1104 // Tap sound
            case "error":
                systemSoundID = 1057 // Error sound
            case "success":
                systemSoundID = 1054 // Success sound
            default:
                systemSoundID = 1104
            }
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
    
}
