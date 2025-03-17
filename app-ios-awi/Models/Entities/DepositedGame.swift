//
//  DepositedGame.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

struct DepositedGame: Identifiable, Codable {
    let tag: String
    let price: Double
    let quantity: Int
    let number_for_sale: Int
    let id_seller: String
    let id_game: Int
    
    var id: String { tag }
}
