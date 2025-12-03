//
//  PatternModel.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation

enum DifficultyLevel: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct PatternModel: Identifiable, Codable {
    let id: UUID
    let sequence: [Int] // Card indices in order
    let displaySpeed: Double
    let timeLimit: Double
    let difficulty: DifficultyLevel
    
    init(id: UUID = UUID(), sequence: [Int], displaySpeed: Double, timeLimit: Double, difficulty: DifficultyLevel) {
        self.id = id
        self.sequence = sequence
        self.displaySpeed = displaySpeed
        self.timeLimit = timeLimit
        self.difficulty = difficulty
    }
}
