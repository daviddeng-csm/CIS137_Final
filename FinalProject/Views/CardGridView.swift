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
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    let sequenceNumber = viewModel.getSequenceNumber(for: index)
                    ChristmasCardView(
                        card: card,
                        size: cardSize,
                        sequenceNumber: sequenceNumber
                    ) {
                        if viewModel.gameState == .playerTurn {
                            viewModel.handleCardTap(at: index)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
