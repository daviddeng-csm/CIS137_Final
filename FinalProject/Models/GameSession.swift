//
//  GameSession.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation

enum GameState: String, Codable {
    case waiting
    case showingPattern
    case playerTurn
    case evaluating
    case completed
    case failed
}

struct GameSession: Identifiable, Codable {
    let id: UUID
    let difficulty: DifficultyLevel
    var currentLevel: Int
    var score: Int
    var lives: Int
    var currentPattern: PatternModel?
    var playerInput: [Int]
    var gameState: GameState
    var startTime: Date
    var timeRemaining: Double
    
    init(id: UUID = UUID(), difficulty: DifficultyLevel, currentLevel: Int = 1, score: Int = 0, lives: Int = 3) {
        self.id = id
        self.difficulty = difficulty
        self.currentLevel = currentLevel
        self.score = score
        self.lives = lives
        self.playerInput = []
        self.gameState = .waiting
        self.startTime = Date()
        self.timeRemaining = 30.0
    }
}
