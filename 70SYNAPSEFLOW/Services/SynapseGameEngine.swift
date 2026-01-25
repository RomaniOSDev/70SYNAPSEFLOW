//
//  SynapseGameEngine.swift
//  70SYNAPSEFLOW
//
//  Created by Роман Главацкий on 25.01.2026.
//

import Foundation
import SwiftUI
import Combine

class SynapseGameEngine: ObservableObject {
    @Published var neurons: [Neuron] = []
    @Published var metrics = GameMetrics()
    @Published var isPlaying = false
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var score: Int = 0
    
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private var startTime: Date?
    private var lastSpawnTime: Date = Date()
    var screenSize: CGSize = UIScreen.main.bounds.size
    var difficulty: DifficultyLevel = .medium
    
    func startGame(difficulty: DifficultyLevel = .medium) {
        self.difficulty = difficulty
        resetGame()
        isPlaying = true
        timeRemaining = difficulty.gameDuration
        startTime = Date()
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateGame()
        }
        
        // Start spawning neurons
        spawnNeuron()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: difficulty.spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnNeuron()
        }
    }
    
    func stopGame() {
        isPlaying = false
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    func resetGame() {
        stopGame()
        neurons.removeAll()
        metrics = GameMetrics()
        timeRemaining = difficulty.gameDuration
        score = 0
    }
    
    private func updateGame() {
        guard isPlaying else { return }
        
        // Update timer
        if let start = startTime {
            let elapsed = Date().timeIntervalSince(start)
            timeRemaining = max(0, GameConstants.gameDuration - elapsed)
            
            if timeRemaining <= 0 {
                endGame()
                return
            }
        }
        
        let now = Date()
        
        // Remove expired neurons (off screen or too old)
        neurons.removeAll { neuron in
            let age = now.timeIntervalSince(neuron.spawnTime)
            // Remove if too old, too transparent, or below screen
            return neuron.position.y > screenSize.height + 100 ||
                   (age > GameConstants.neuronLifetime && neuron.opacity < 0.1)
        }
        
        // Update neuron positions and opacity
        for index in neurons.indices {
            neurons[index].position.x += neurons[index].velocity.x
            neurons[index].position.y += neurons[index].velocity.y
            
            let age = now.timeIntervalSince(neurons[index].spawnTime)
            // Only start fading when near the end of lifetime
            let fadeStart = GameConstants.neuronLifetime * 0.7
            if age > fadeStart {
                let fadeRatio = (age - fadeStart) / (GameConstants.neuronLifetime - fadeStart)
                neurons[index].opacity = max(0, 1.0 - fadeRatio)
            }
        }
    }
    
    private func spawnNeuron() {
        guard isPlaying else { return }
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        // Random position - spawn in upper visible area
        let x = CGFloat.random(in: 60...(screenWidth - 60))
        let y = CGFloat.random(in: 80...150) // Start in visible upper area
        
        // Random size
        let size = CGFloat.random(in: GameConstants.minNeuronSize...GameConstants.maxNeuronSize)
        
        // Signal ratio based on difficulty
        let signalRatio = difficulty.signalRatio
        let type: NeuronType = Double.random(in: 0...1) < signalRatio ? .signal : .noise
        
        // Random velocity with slight horizontal drift - speed based on difficulty
        let baseSpeed = difficulty.neuronSpeed
        let velocity = CGPoint(
            x: CGFloat.random(in: -0.8...0.8),
            y: CGFloat.random(in: baseSpeed...(baseSpeed + 3.0))
        )
        
        let neuron = Neuron(
            type: type,
            position: CGPoint(x: x, y: y),
            size: size,
            opacity: 1.0,
            spawnTime: Date(),
            velocity: velocity
        )
        
        neurons.append(neuron)
        
        // Update metrics
        if type == .signal {
            metrics.totalSignals += 1
        } else {
            metrics.totalNoise += 1
        }
        
        metrics.timeStamps.append(Date())
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard isPlaying else { return false }
        
        // Find tapped neuron
        guard let tappedIndex = neurons.firstIndex(where: { neuron in
            let distance = sqrt(
                pow(neuron.position.x - location.x, 2) +
                pow(neuron.position.y - location.y, 2)
            )
            return distance < neuron.size / 2
        }) else {
            return false
        }
        
        let tappedNeuron = neurons[tappedIndex]
        let tapTime = Date()
        
        // Calculate reaction time if it's a signal
        if tappedNeuron.type == .signal {
            if let lastSignalTime = metrics.timeStamps.last {
                let reactionTime = tapTime.timeIntervalSince(lastSignalTime)
                if reactionTime > 0 && reactionTime < 5.0 {
                    metrics.reactionTime.append(reactionTime)
                }
            }
            
            metrics.correctTaps += 1
            score += 10
            neurons.remove(at: tappedIndex)
            
            // Play sound
            SoundManager.shared.playSound("tap")
            
            // Animate pulse effect
            withAnimation(.easeOut(duration: 0.3)) {
                // Neuron removed, create pulse effect
            }
            
            return true
        } else {
            // Tapped noise - error
            metrics.incorrectTaps += 1
            metrics.errors += 1
            score = max(0, score - 5)
            neurons.remove(at: tappedIndex)
            
            // Play error sound
            SoundManager.shared.playSound("error")
            
            return false
        }
    }
    
    private func endGame() {
        stopGame()
        // Finalize metrics
        metrics.accuracy = metrics.correctTaps
    }
    
    func getFinalMetrics() -> GameMetrics {
        return metrics
    }
}
