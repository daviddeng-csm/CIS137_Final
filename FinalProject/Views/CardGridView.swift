//
//  CardGridView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct CardGridView: View {
    let viewModel: PatternGameViewModel
    let columns: [GridItem]
    let cardSize: CGFloat
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                ChristmasCardView(
                    card: card,
                    size: cardSize,
                    onTap: {
                        if viewModel.gameState == .playerTurn {
                            viewModel.handleCardTap(at: index)
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}
