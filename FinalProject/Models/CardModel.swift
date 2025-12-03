//
//  CardModel.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import Foundation

struct CardModel: Identifiable, Equatable {
    let id: UUID
    let imageName: String
    var isFaceUp: Bool
    var isMatched: Bool
    
    init(id: UUID = UUID(), imageName: String, isFaceUp: Bool = false, isMatched: Bool = false) {
        self.id = id
        self.imageName = imageName
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
    }
    
    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.id == rhs.id
    }
}
