//
//  StorageManager.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation

class StorageManager {
    private let highScoresKey = "patternPulseHighScores"
    private let savedSessionsKey = "patternPulseSavedSessions"
    
    func saveHighScores(_ scores: [HighScore]) {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }
    
    func loadHighScores() -> [HighScore] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([HighScore].self, from: data) else {
            return []
        }
        return scores
    }
    
    func saveSessions(_ sessions: [GameSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: savedSessionsKey)
        }
    }
    
    func loadSessions() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: savedSessionsKey),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }
}
