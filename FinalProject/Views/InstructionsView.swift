//
//  InstructionsView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                Text("How to Play Pattern Pulse")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                InstructionStep(
                    number: 1,
                    title: "Watch the Pattern",
                    description: "Christmas cards will light up in a specific sequence. Pay close attention to the order!"
                )
                
                InstructionStep(
                    number: 2,
                    title: "Repeat the Sequence",
                    description: "Tap the cards in the exact same order you saw them. Take your time!"
                )
                
                InstructionStep(
                    number: 3,
                    title: "Advance Levels",
                    description: "Each correct pattern takes you to the next level with longer, faster sequences."
                )
                
                InstructionStep(
                    number: 4,
                    title: "Manage Your Lives",
                    description: "You start with 3 lives. Lose 1 life for each incorrect sequence. Game over when lives reach 0."
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scoring")
                        .font(.title2.bold())
                    
                    Text("• Base points increase with difficulty")
                    Text("• Time bonus for quick completion")
                    Text("• Level bonus for higher levels")
                    Text("• Only 1 life lost per wrong sequence")
                    Text("• Time limit decreases at higher levels")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Difficulty Levels")
                        .font(.title2.bold())
                    
                    Text("• Easy: Slow patterns, 30 seconds per turn")
                    Text("• Medium: Moderate speed, 25 seconds per turn")
                    Text("• Hard: Fast patterns, 20 seconds per turn")
                    Text("• Patterns get faster with each level")
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips")
                        .font(.title2.bold())
                    
                    Text("• Say the pattern out loud as you watch")
                    Text("• Look for visual patterns in the Christmas images")
                    Text("• Start with Easy mode to learn the game")
                    Text("• Save your game to continue later")
                    Text("• Use the 'Continue Game' option for saved progress")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                
                Text("Note: Your game is automatically saved after each level. You can continue any unfinished game from the main menu.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
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

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                
                Text("\(number)")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
        .background(Color.white.opacity(0.7)) // Add white background for readability
        .cornerRadius(10)
        .padding(.horizontal, 5)
    }
}
