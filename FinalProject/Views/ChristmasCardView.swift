//
//  ChristmasCardView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct ChristmasCardView: View {
    let card: CardModel
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp ? Color.white : Color.red.opacity(0.8))
                .shadow(radius: 3)
            
            if card.isFaceUp {
                // Front of card - shows Christmas image
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                // Back of card - shows Christmas pattern
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.red, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Text("🎄")
                            .font(.system(size: size * 0.35))
                    )
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(card.isFaceUp ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isFaceUp)
        .onTapGesture {
            onTap()
        }
    }
}

struct GameButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
