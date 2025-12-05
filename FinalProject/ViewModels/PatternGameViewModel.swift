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
    
    @Published var showNameAlert = false
    @Published var tempHighScore: HighScore?
    
    private let storage = StorageManager()
    private let totalCards = 9 // 3x3 grid
    private var timer: Timer?
    private var currentStep: Int = 0
    private var lastDifficulty: DifficultyLevel = .medium
    
    init() {
        print("DEBUG: PatternGameViewModel initialized")
        loadHighScores()
        loadSavedSessions()
        initializeCards()
        
        // Debug: Print loaded sessions
        print("DEBUG: Loaded \(savedSessions.count) saved sessions")
        for session in savedSessions {
            print("  - Level \(session.currentLevel), Score: \(session.score), Lives: \(session.lives)")
        }
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
        print("DEBUG: Starting new game with difficulty: \(difficulty)")
        
        // Store this difficulty for future use
        lastDifficulty = difficulty
        
        // Invalidate timer
        timer?.invalidate()
        timer = nil
        
        // Create new session
        let newSession = GameSession(difficulty: difficulty)
        currentSession = newSession
        gameState = .waiting
        
        // Reset cards
        resetCards()
        
        print("DEBUG: New session created - Level: \(newSession.currentLevel), Lives: \(newSession.lives)")
        
        // Generate the first pattern
        generateNewPattern(for: newSession)
    }
    
    func resumeGame(session: GameSession) {
        print("DEBUG: Resuming game session - Level \(session.currentLevel), Score: \(session.score)")
        
        // Store this difficulty
        lastDifficulty = session.difficulty
        
        resetCards()
        currentSession = session
        gameState = .waiting
        generateNewPattern(for: session)
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
            resetCards()
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Reset step counter
            currentStep = 0
            
            // Show each card in sequence
            for cardIndex in pattern.sequence {
                currentStep += 1
                
                // Set sequence number for this specific display moment
                cards[cardIndex].sequenceNumber = currentStep
                cards[cardIndex].isFaceUp = true
                
                try? await Task.sleep(nanoseconds: UInt64(pattern.displaySpeed * 1_000_000_000))
                
                cards[cardIndex].isFaceUp = false
                cards[cardIndex].sequenceNumber = nil // Clear after display
                
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            
            currentStep = 0 // Reset for player turn
            gameState = .playerTurn
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
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
            handleWrongSequence()
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
    
    private func handleWrongSequence() {
        guard var session = currentSession else { return }
        
        // Lose only 1 life per wrong sequence, regardless of how many wrong cards
        session.lives = max(0, session.lives - 1)
        session.playerInput = []
        currentSession = session
        
        // Show which cards were wrong before moving on
        showWrongFeedback { [weak self] in
            guard let self = self else { return }
            
            if session.lives <= 0 {
                self.gameState = .failed
                // Don't delete session here - keep it for game over screen
                self.triggerHighScoreSave()  // Trigger high score save
            } else {
                self.saveCurrentSession()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.resetCards()
                    self.gameState = .waiting
                    self.currentSession?.playerInput = []
                    if let updatedSession = self.currentSession {
                        self.generateNewPattern(for: updatedSession)
                    }
                }
            }
        }
    }
    
    // Helper method to show visual feedback for wrong sequence
    private func showWrongFeedback(completion: @escaping () -> Void) {
        Task {
            // Briefly show the correct pattern again
            if let pattern = currentSession?.currentPattern {
                for cardIndex in pattern.sequence {
                    cards[cardIndex].isFaceUp = true
                }
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            resetCards()
            completion()
        }
    }
    
    private func handleTimeOut() {
        currentSession?.lives = 0
        gameState = .failed
        // Don't delete session here - keep it for game over screen
        triggerHighScoreSave()  // Trigger high score save
    }
    
    // New method to trigger high score save with name input
    private func triggerHighScoreSave() {
        guard let session = currentSession, session.score > 0 else {
            print("DEBUG: No session or score is 0, skipping high score save")
            return
        }
        
        print("DEBUG: Triggering high score save for score: \(session.score)")
        
        // Create temporary high score
        tempHighScore = HighScore(
            playerName: "Player", // Default name
            score: session.score,
            difficulty: session.difficulty,
            levelReached: session.currentLevel
        )
        
        // Show alert for player to enter name
        showNameAlert = true
    }
    
    func confirmHighScore(with name: String) {
        guard var score = tempHighScore else { return }
        
        // Update name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        score.playerName = trimmedName.isEmpty ? "Player" : trimmedName
        
        // Save to high scores
        highScores.append(score)
        highScores.sort { $0.score > $1.score }
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        storage.saveHighScores(highScores)
        
        // Clear temp
        tempHighScore = nil
        showNameAlert = false
        
        print("DEBUG: High score saved: \(score.playerName) - \(score.score)")
        
        // Debug: Print saved high scores
        print("DEBUG: High scores after save:")
        for (index, savedScore) in highScores.enumerated() {
            print("  \(index + 1). \(savedScore.playerName): \(savedScore.score) - Level \(savedScore.levelReached)")
        }
    }
    
    func cancelHighScore() {
        // If cancelled, save with default name "Player"
        if let score = tempHighScore {
            highScores.append(score)
            highScores.sort { $0.score > $1.score }
            if highScores.count > 10 {
                highScores = Array(highScores.prefix(10))
            }
            storage.saveHighScores(highScores)
        }
        
        tempHighScore = nil
        showNameAlert = false
        print("DEBUG: High score saved with default name")
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
    
    func getSequenceNumber(for index: Int) -> Int? {
        // During pattern display, return the sequence number if set
        if gameState == .showingPattern {
            return cards[index].sequenceNumber
        }
        return nil
    }
    
    func getLastDifficulty() -> DifficultyLevel {
        return lastDifficulty
    }
    
    private func resetCards() {
        for i in cards.indices {
            cards[i].isFaceUp = false
        }
    }
    
    // MARK: - Persistent Storage
    
    func saveCurrentSession() {
        guard let session = currentSession, session.lives > 0 else { return }
        
        // Remove old saved session if exists
        savedSessions.removeAll { $0.id == session.id }
        savedSessions.append(session)
        storage.saveSessions(savedSessions)
    }
    
    func deleteSession(_ session: GameSession) {
        savedSessions.removeAll { $0.id == session.id }
        storage.saveSessions(savedSessions)
        
        // If deleting the current session, clear it
        if currentSession?.id == session.id {
            currentSession = nil
        }
    }
    
    func saveHighScores() {
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
