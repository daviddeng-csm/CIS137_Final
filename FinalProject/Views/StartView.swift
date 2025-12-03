//
//  StartView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: PatternGameViewModel
    @State private var selectedDifficulty: DifficultyLevel = .medium
    @State private var navigateToGame = false
    @State private var navigateToHighScores = false
    @State private var navigateToInstructions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("🎄 Pattern Pulse")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Sequence Memory Game")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Difficulty Selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select Difficulty")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty,
                            action: {
                                selectedDifficulty = difficulty
                            }
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                // Saved Games
                if !viewModel.savedSessions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Continue Game")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(viewModel.savedSessions) { session in
                            SavedGameCard(session: session) {
                                viewModel.resumeGame(session: session)
                                navigateToGame = true
                            } onDelete: {
                                viewModel.deleteSession(session)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 20) {
                    Button(action: {
                        viewModel.startNewGame(difficulty: selectedDifficulty)
                        navigateToGame = true
                    }) {
                        Text("New Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        navigateToHighScores = true
                    }) {
                        Text("High Scores")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        navigateToInstructions = true
                    }) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                
                // Hidden NavigationLinks
                NavigationLink(
                    destination: GameView(viewModel: viewModel),
                    isActive: $navigateToGame,
                    label: { EmptyView() }
                )
                
                NavigationLink(
                    destination: HighScoresView(viewModel: viewModel),
                    isActive: $navigateToHighScores,
                    label: { EmptyView() }
                )
                
                NavigationLink(
                    destination: InstructionsView(),
                    isActive: $navigateToInstructions,
                    label: { EmptyView() }
                )
            }
            .background(
                Image("christmas-background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
            )
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct DifficultyCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(difficulty.rawValue)
                        .font(.title3.bold())
                    
                    Text(difficultyDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var difficultyDescription: String {
        switch difficulty {
        case .easy:
            return "Slow patterns, more time"
        case .medium:
            return "Moderate speed, balanced"
        case .hard:
            return "Fast patterns, less time"
        }
    }
}

struct SavedGameCard: View {
    let session: GameSession
    let action: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Level \(session.currentLevel)")
                        .font(.headline)
                    
                    HStack {
                        Text(session.difficulty.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(6)
                        
                        Text("Score: \(session.score)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Lives: \(session.lives)")
                            .font(.caption)
                            .foregroundColor(session.lives > 1 ? .green : .red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
    }
}
