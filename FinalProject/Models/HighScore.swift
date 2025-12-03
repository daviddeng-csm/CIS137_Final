//
//  HighScore.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation

struct HighScore: Identifiable, Codable, Comparable {
    let id: UUID
    let playerName: String
    let score: Int
    let difficulty: DifficultyLevel
    let date: Date
    let levelReached: Int
    
    init(id: UUID = UUID(), playerName: String, score: Int, difficulty: DifficultyLevel, levelReached: Int) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.difficulty = difficulty
        self.date = Date()
        self.levelReached = levelReached
    }
    
    static func < (lhs: HighScore, rhs: HighScore) -> Bool {
        return lhs.score < rhs.score
    }
    
    static func == (lhs: HighScore, rhs: HighScore) -> Bool {
        return lhs.id == rhs.id
    }
}
