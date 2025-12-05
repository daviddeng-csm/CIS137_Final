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
    let sequenceNumber: Int?
    let onTap: () -> Void
    
    @State private var isPulsing = false
    @State private var tapScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Card background with pulse overlay
            RoundedRectangle(cornerRadius: 12)
                .fill(card.isFaceUp ? Color.white : Color.red.opacity(0.8))
                .shadow(radius: 3)
                .overlay(
                    // Pulse effect
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow, lineWidth: isPulsing ? 4 : 0)
                        .scaleEffect(isPulsing ? 1.05 : 1.0)
                        .opacity(isPulsing ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.3), value: isPulsing)
                )
            
            if card.isFaceUp {
                // Front of card
                VStack {
                    Image(card.imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                    
                    if let sequenceNumber = sequenceNumber {
                        Text("\(sequenceNumber)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.blue))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(tapScale)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: tapScale)
            } else {
                // Back of card
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
                    .scaleEffect(tapScale)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: tapScale)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(card.isFaceUp ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
        .onTapGesture {
            triggerTapFeedback()
            onTap()
        }
    }
    
    private func triggerTapFeedback() {
        // 1. Scale down briefly
        tapScale = 0.95
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tapScale = 1.0
        }
        
        // 2. Start pulse animation
        isPulsing = true
        
        // 3. End pulse animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPulsing = false
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
