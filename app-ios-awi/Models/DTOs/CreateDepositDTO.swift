//
//  CreateDepositDTO.swift
//  app-ios-awi
//
//  Created by etud on 21/03/2025.
//

import Foundation

struct CreateDepositDto: Codable {
    let date: Date
    let amount: Double
    let fees: Double
    let discount: Double
    let id_seller: String
    let id_session: Int
    let games_deposited: [GameDepositedDto]
}

struct GameDepositedDto: Codable {
    let id_game: Int
    let quantity: Int
    let price: Double
    let nb_for_sale: Int
}
