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
    var sequenceNumber: Int?
    
    init(id: UUID = UUID(), imageName: String, isFaceUp: Bool = false, isMatched: Bool = false, sequenceNumber: Int? = nil) {
        self.id = id
        self.imageName = imageName
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
        self.sequenceNumber = sequenceNumber
    }
    
    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.id == rhs.id
    }
}
