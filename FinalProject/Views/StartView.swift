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
            VStack(spacing: 0) {
                // Fixed Header
                VStack(spacing: 10) {
                    Text("Pattern Pulse")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("Sequence Memory Game")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
                .background(
                    Image("christmas-background")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.1)
                )
                
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 25) {
                        // Icon Buttons Row (High Scores & Instructions)
                        HStack(spacing: 40) {
                            Button(action: {
                                navigateToHighScores = true
                            }) {
                                VStack(spacing: 5) {
                                    Image(systemName: "trophy")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                    
                                    Text("Scores")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Button(action: {
                                navigateToInstructions = true
                            }) {
                                VStack(spacing: 5) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text("Help")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        // Difficulty Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select Difficulty")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 30)
                            
                            ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                                DifficultyCard(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty,
                                    action: {
                                        selectedDifficulty = difficulty
                                    }
                                )
                                .padding(.horizontal, 30)
                            }
                        }
                        
                        // Saved Games Section
                        if !viewModel.savedSessions.isEmpty {
                            let activeSessions = viewModel.savedSessions.filter { !$0.isGameOver }
                            
                            if !activeSessions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Continue Game")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 30)
                                    
                                    ForEach(viewModel.savedSessions) { session in
                                        SavedGameCard(session: session) {
                                            // FIX: Add a small delay to ensure ViewModel updates before navigation
                                            DispatchQueue.main.async {
                                                viewModel.resumeGame(session: session)
                                                // FIX: Use a small delay to ensure state is set
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    navigateToGame = true
                                                }
                                            }
                                        } onDelete: {
                                            viewModel.deleteSession(session)
                                        }
                                        .padding(.horizontal, 30)
                                    }
                                }
                                .padding(.top, 10)
                            }
                            
                        }
                        
                        Spacer(minLength: 20)
                        
                        // New Game Button (Large)
                        Button(action: {
                            viewModel.startNewGame(difficulty: selectedDifficulty)
                            // FIX: Add a small delay to ensure state is set
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateToGame = true
                            }
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                
                                Text("New Game")
                                    .font(.title2.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                    .padding(.vertical, 20)
                }
                .background(Color.white.opacity(0.01))
                
                // Hidden NavigationLinks
                NavigationLink(
                    destination: GameView(viewModel: viewModel)
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToGame,
                    label: { EmptyView() }
                )
                
                NavigationLink(
                    destination: HighScoresView(viewModel: viewModel)
                        .navigationBarBackButtonHidden(false),
                    isActive: $navigateToHighScores,
                    label: { EmptyView() }
                )
                
                NavigationLink(
                    destination: InstructionsView()
                        .navigationBarBackButtonHidden(false),
                    isActive: $navigateToInstructions,
                    label: { EmptyView() }
                )
            }
            .edgesIgnoringSafeArea(.top)
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
                // Difficulty Icon
                Image(systemName: difficultyIcon)
                    .font(.title3)
                    .foregroundColor(difficultyColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
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
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? difficultyColor.opacity(0.1) : Color.gray.opacity(0.07))
                    .stroke(isSelected ? difficultyColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private var difficultyIcon: String {
        switch difficulty {
        case .easy: return "tortoise"
        case .medium: return "person"
        case .hard: return "hare"
        }
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
                HStack {
                    // Game Status Icon
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Level \(session.currentLevel)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Text(session.difficulty.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(difficultyColor.opacity(0.2))
                                .cornerRadius(6)
                            
                            Text("Score: \(session.score)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 3) {
                                ForEach(0..<session.lives, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Continue Arrow
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.7))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
    }
    
    private var difficultyColor: Color {
        switch session.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
