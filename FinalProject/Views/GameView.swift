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
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with game info
            GameHeader(viewModel: viewModel)
            
            // Timer
            TimerBar(viewModel: viewModel)
            
            // Game Status
            GameStatusView(viewModel: viewModel)
            
            // Card Grid - Now using the CardGridView from a separate file
            CardGridView(
                viewModel: viewModel,
                columns: columns,
                cardSize: 100
            )
            
            // Controls
            if viewModel.gameState == .failed {
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.red)
                    
                    Text("Final Score: \(viewModel.currentSession?.score ?? 0)")
                        .font(.title2)
                    
                    HStack(spacing: 20) {
                        Button("Main Menu") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyle(GameButtonStyle(color: .blue))
                        
                        Button("Play Again") {
                            print("DEBUG: Play Again button pressed")
                            // Use the last difficulty stored in viewModel
                            viewModel.startNewGame(difficulty: viewModel.getLastDifficulty())
                        }
                        .buttonStyle(GameButtonStyle(color: .green))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            
            Spacer()
        }
        .padding()
        .background(
            Image("christmas-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.1)
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .onAppear {
            print("DEBUG: GameView appeared. Current session: \(viewModel.currentSession != nil ? "Exists" : "Nil")")
            print("DEBUG: Game state: \(viewModel.gameState)")
        }
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
            if viewModel.gameState == .playerTurn {
                ProgressView(value: viewModel.currentSession?.timeRemaining ?? 0, total: 30)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .animation(.linear, value: viewModel.currentSession?.timeRemaining)
                
                Text("Time: \(String(format: "%.1f", viewModel.currentSession?.timeRemaining ?? 0))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
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
