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
                    description: "Cards will light up in a specific sequence. Pay close attention!"
                )
                
                InstructionStep(
                    number: 2,
                    title: "Repeat the Sequence",
                    description: "Tap the cards in the exact same order you saw them."
                )
                
                InstructionStep(
                    number: 3,
                    title: "Advance Levels",
                    description: "Each correct pattern takes you to the next level with longer sequences."
                )
                
                InstructionStep(
                    number: 4,
                    title: "Manage Your Time",
                    description: "Complete patterns before time runs out! You start with 3 lives."
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scoring")
                        .font(.title2.bold())
                    
                    Text("• Base points increase with difficulty")
                    Text("• Time bonus for quick completion")
                    Text("• Level bonus for higher levels")
                    Text("• Lose a life for incorrect patterns")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips")
                        .font(.title2.bold())
                    
                    Text("• Say the pattern out loud")
                    Text("• Look for visual patterns")
                    Text("• Start with Easy mode to learn")
                    Text("• Save your game to continue later")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(
            Image("christmas-background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.1)
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
                
                Text(description)
                    .foregroundColor(.secondary)
            }
        }
    }
}
