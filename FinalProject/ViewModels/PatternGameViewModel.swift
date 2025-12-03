//
//  PatternGameViewModel.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation
import SwiftUI

@MainActor
final class PatternGameViewModel: ObservableObject {
    @Published var currentSession: GameSession?
    @Published var gameState: GameState = .waiting
    @Published var highScores: [HighScore] = []
    @Published var savedSessions: [GameSession] = []
    @Published var cards: [CardModel] = []
    
    private let storage = StorageManager()
    private let totalCards = 9 // 3x3 grid
    private var timer: Timer?
    
    init() {
        loadHighScores()
        loadSavedSessions()
        initializeCards()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func initializeCards() {
        // Randomly select 9 unique images from your 18 Christmas images
        let availableImages = 18
        let neededImages = 9
        
        // Create array of indices 1...18, shuffle, take first 9
        let randomIndices = Array(1...availableImages).shuffled().prefix(neededImages)
        
        cards = randomIndices.map { index in
            CardModel(imageName: "christmas\(index)")
        }
    }
    
    func startNewGame(difficulty: DifficultyLevel) {
        let newSession = GameSession(difficulty: difficulty)
        currentSession = newSession
        gameState = .waiting
        generateNewPattern(for: newSession)
    }
    
    func resumeGame(session: GameSession) {
        currentSession = session
        gameState = .waiting
    }
    
    func generateNewPattern(for session: GameSession) {
        let patternLength = calculatePatternLength(for: session.currentLevel, difficulty: session.difficulty)
        let sequence = generateRandomSequence(length: patternLength, maxIndex: totalCards - 1)
        let displaySpeed = calculateDisplaySpeed(for: session.difficulty, level: session.currentLevel)
        let timeLimit = calculateTimeLimit(for: session.difficulty, level: session.currentLevel)
        
        let pattern = PatternModel(
            sequence: sequence,
            displaySpeed: displaySpeed,
            timeLimit: timeLimit,
            difficulty: session.difficulty
        )
        
        currentSession?.currentPattern = pattern
        gameState = .showingPattern
        
        // Show pattern to player
        showPattern(pattern)
    }
    
    private func showPattern(_ pattern: PatternModel) {
        Task {
            // Reset all cards to face down
            resetCards()
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
            
            // Show each card in sequence
            for cardIndex in pattern.sequence {
                cards[cardIndex].isFaceUp = true
                try? await Task.sleep(nanoseconds: UInt64(pattern.displaySpeed * 1_000_000_000))
                cards[cardIndex].isFaceUp = false
                try? await Task.sleep(nanoseconds: 200_000_000) // Small pause between cards
            }
            
            // Player's turn
            gameState = .playerTurn
            currentSession?.timeRemaining = pattern.timeLimit
            currentSession?.playerInput = []
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.gameState == .playerTurn else { return }
            
            if let timeRemaining = self.currentSession?.timeRemaining {
                self.currentSession?.timeRemaining = timeRemaining - 0.1
                
                if self.currentSession?.timeRemaining ?? 0 <= 0 {
                    self.timer?.invalidate()
                    self.handleTimeOut()
                }
            }
        }
    }
    
    func handleCardTap(at index: Int) {
        guard gameState == .playerTurn, let session = currentSession else { return }
        
        cards[index].isFaceUp = true
        currentSession?.playerInput.append(index)
        
        // Check if input matches pattern
        if let pattern = session.currentPattern {
            let inputLength = currentSession?.playerInput.count ?? 0
            
            if inputLength == pattern.sequence.count {
                evaluatePattern()
            } else {
                // Check if current input matches so far
                for i in 0..<inputLength {
                    if currentSession?.playerInput[i] != pattern.sequence[i] {
                        handleWrongInput()
                        return
                    }
                }
            }
        }
    }
    
    private func evaluatePattern() {
        gameState = .evaluating
        
        guard let session = currentSession,
              let pattern = session.currentPattern else { return }
        
        let isCorrect = session.playerInput == pattern.sequence
        
        if isCorrect {
            handleCorrectPattern()
        } else {
            handleWrongInput()
        }
    }
    
    private func handleCorrectPattern() {
        guard var session = currentSession else { return }
        
        session.score += calculateScore(for: session)
        session.currentLevel += 1
        session.playerInput = []
        currentSession = session
        
        saveCurrentSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.generateNewPattern(for: session)
        }
    }
    
    private func handleWrongInput() {
        guard var session = currentSession else { return }
        
        session.lives -= 1
        session.playerInput = []
        currentSession = session
        
        if session.lives <= 0 {
            gameState = .failed
            saveHighScore()
        } else {
            // Show wrong feedback briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetCards()
                self.gameState = .playerTurn
                self.currentSession?.playerInput = []
            }
        }
    }
    
    private func handleTimeOut() {
        gameState = .failed
        saveHighScore()
    }
    
    private func calculateScore(for session: GameSession) -> Int {
        let baseScore: Int
        switch session.difficulty {
        case .easy: baseScore = 100
        case .medium: baseScore = 200
        case .hard: baseScore = 300
        }
        
        let timeBonus = Int((session.timeRemaining / 30) * 50)
        return baseScore + timeBonus + (session.currentLevel * 10)
    }
    
    private func calculatePatternLength(for level: Int, difficulty: DifficultyLevel) -> Int {
        let baseLength: Int
        switch difficulty {
        case .easy: baseLength = 2
        case .medium: baseLength = 3
        case .hard: baseLength = 4
        }
        
        return baseLength + (level / 3)
    }
    
    private func calculateDisplaySpeed(for difficulty: DifficultyLevel, level: Int) -> Double {
        let baseSpeed: Double
        switch difficulty {
        case .easy: baseSpeed = 1.2
        case .medium: baseSpeed = 0.9
        case .hard: baseSpeed = 0.6
        }
        
        return max(0.3, baseSpeed - (Double(level) * 0.05))
    }
    
    private func calculateTimeLimit(for difficulty: DifficultyLevel, level: Int) -> Double {
        let baseTime: Double
        switch difficulty {
        case .easy: baseTime = 30.0
        case .medium: baseTime = 25.0
        case .hard: baseTime = 20.0
        }
        
        return max(10.0, baseTime - (Double(level) * 0.5))
    }
    
    private func generateRandomSequence(length: Int, maxIndex: Int) -> [Int] {
        var sequence: [Int] = []
        while sequence.count < length {
            let randomIndex = Int.random(in: 0...maxIndex)
            sequence.append(randomIndex)
        }
        return sequence
    }
    
    private func resetCards() {
        for i in cards.indices {
            cards[i].isFaceUp = false
        }
    }
    
    // MARK: - Persistent Storage
    
    func saveCurrentSession() {
        guard let session = currentSession else { return }
        
        // Remove old saved session if exists
        savedSessions.removeAll { $0.id == session.id }
        savedSessions.append(session)
        storage.saveSessions(savedSessions)
    }
    
    func deleteSession(_ session: GameSession) {
        savedSessions.removeAll { $0.id == session.id }
        storage.saveSessions(savedSessions)
    }
    
    func saveHighScore() {
        guard let session = currentSession else { return }
        
        let highScore = HighScore(
            playerName: "Player",
            score: session.score,
            difficulty: session.difficulty,
            levelReached: session.currentLevel
        )
        
        highScores.append(highScore)
        highScores.sort { $0.score > $1.score }
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        storage.saveHighScores(highScores)
    }
    
    func clearHighScores() {
        highScores = []
        storage.saveHighScores([])
    }
    
    private func loadHighScores() {
        highScores = storage.loadHighScores()
    }
    
    private func loadSavedSessions() {
        savedSessions = storage.loadSessions()
    }
}
