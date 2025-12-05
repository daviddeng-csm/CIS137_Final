//
//  HighScoresView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct HighScoresView: View {
    @ObservedObject var viewModel: PatternGameViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("High Scores")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.top)
            
            if viewModel.highScores.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "trophy")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No high scores yet!")
                        .foregroundColor(.secondary)
                    Text("Play a game to get on the leaderboard!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.highScores.enumerated()), id: \.element.id) { index, score in
                        HighScoreRow(index: index + 1, score: score)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
            
            Button("Clear All Scores") {
                viewModel.clearHighScores()
            }
            .buttonStyle(GameButtonStyle(color: .red))
            .padding()
        }
        .background(
            Image("christmas-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.35)
        )
    }
}

struct HighScoreRow: View {
    let index: Int
    let score: HighScore
    
    var body: some View {
        HStack {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(index)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(score.playerName)
                    .font(.headline)
                
                HStack {
                    Text("Level \(score.levelReached)")
                        .font(.caption)
                    
                    Text(score.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.2))
                        .cornerRadius(4)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score.score)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text(score.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.7)) // Add white background for readability
    }
    
    private var rankColor: Color {
        switch index {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var difficultyColor: Color {
        switch score.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
