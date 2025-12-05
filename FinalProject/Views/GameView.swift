//
//  GameView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: PatternGameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var playerNameInput = ""
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            // Background FIRST (behind everything)
            Image("christmas-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.3)
            
            // Main content
            VStack(spacing: 15) {
                // Header with game info
                GameHeader(viewModel: viewModel)
                
                // Timer - Always visible but shows progress only during player turn
                TimerBar(viewModel: viewModel)
                
                // Game Status
                GameStatusView(viewModel: viewModel)
                    .padding(.horizontal)
                
                Spacer()
                
                // Card Grid with fixed spacing
                CardGridView(
                    viewModel: viewModel,
                    columns: columns,
                    cardSize: 90  // Fixed size instead of dynamic
                )
                
                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
            
            // Game Over Overlay (like Halloween version)
            if viewModel.gameState == .failed {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        GameOverOverlay(viewModel: viewModel, presentationMode: presentationMode)
                    )
            }
        }
        .alert("🎉 New High Score! 🎉", isPresented: $viewModel.showNameAlert) {
            TextField("Enter your name", text: $playerNameInput)
                .autocapitalization(.words)
            
            Button("Save") {
                viewModel.confirmHighScore(with: playerNameInput)
                playerNameInput = ""
            }
            .disabled(playerNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button("Skip", role: .cancel) {
                viewModel.cancelHighScore()
                playerNameInput = ""
            }
        } message: {
            if let tempScore = viewModel.tempHighScore {
                Text("Congratulations! You scored \(tempScore.score) points!\nEnter your name for the leaderboard:")
            }
        }
        .onChange(of: viewModel.showNameAlert) { showing in
            if showing {
                playerNameInput = "Player" // Default value
            }
        }
    }
}

struct GameOverOverlay: View {
    @ObservedObject var viewModel: PatternGameViewModel
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Game Over")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.red)
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Text("\(viewModel.currentSession?.score ?? 0)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 15) {
                Text("Level Reached")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                Text("\(viewModel.currentSession?.currentLevel ?? 1)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 20) {
                Button("Play Again") {
                    print("DEBUG: Play Again button pressed")
                    // Clean up the old session first
                    if let session = viewModel.currentSession {
                        viewModel.deleteSession(session)
                    }
                    // Use the last difficulty stored in viewModel
                    viewModel.startNewGame(difficulty: viewModel.getLastDifficulty())
                }
                .buttonStyle(GameButtonStyle(color: .green))
                .frame(width: 200)
                
                Button("Main Menu") {
                    // Clean up the old session before going back
                    if let session = viewModel.currentSession {
                        viewModel.deleteSession(session)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(GameButtonStyle(color: .blue))
                .frame(width: 200)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 20)
        )
        .padding(30)
    }
}

// MARK: - Game Header Component
struct GameHeader: View {
    @ObservedObject var viewModel: PatternGameViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let session = viewModel.currentSession {
                    Text("Level \(session.currentLevel)")
                        .font(.title.bold())
                    
                    Text(session.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Score: \(viewModel.currentSession?.score ?? 0)")
                    .font(.title2.bold())
                
                HStack(spacing: 20) {
                    let lives = viewModel.currentSession?.lives ?? 0
                    HStack(spacing: 5) {
                        if lives > 0 {
                            ForEach(0..<lives, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                        } else {
                            // Show broken heart when game over
                            Image(systemName: "heart.slash")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Timer Component
struct TimerBar: View {
    @ObservedObject var viewModel: PatternGameViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            if viewModel.gameState == .playerTurn, let timeRemaining = viewModel.currentSession?.timeRemaining {
                // Show progress bar during player's turn
                ProgressView(value: timeRemaining, total: 30)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .animation(.linear, value: timeRemaining)
                
                Text("Time: \(String(format: "%.1f", timeRemaining))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Show empty space to maintain layout
                Text("")
                    .frame(height: 20)
            }
        }
        .padding(.horizontal)
        .frame(height: 40)
    }
    
    private var progressColor: Color {
        guard let timeRemaining = viewModel.currentSession?.timeRemaining else { return .blue }
        
        if timeRemaining > 20 {
            return .green
        } else if timeRemaining > 10 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Game Status Component
struct GameStatusView: View {
    @ObservedObject var viewModel: PatternGameViewModel
    
    var body: some View {
        Group {
            switch viewModel.gameState {
            case .showingPattern:
                Text("Watch the pattern...")
                    .font(.headline)
                    .foregroundColor(.blue)
            case .playerTurn:
                Text("Your turn! Repeat the pattern")
                    .font(.headline)
                    .foregroundColor(.green)
            case .evaluating:
                Text("Checking...")
                    .font(.headline)
                    .foregroundColor(.orange)
            case .failed:
                Text("Game Over!")
                    .font(.headline)
                    .foregroundColor(.red)
            default:
                Text("Get ready...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: - Back Button Component
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.blue)
        }
    }
}
