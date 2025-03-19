//
//  Deposit.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct GamesDeposited: Codable, Identifiable {
    let id: String
    var id_game: Int
    var quantity: Int
    var price: Double
    var nb_for_sale: Int
}

struct Deposit: Identifiable, Codable {
    var id_deposit: String
    var id_game: Int
    var quantity: Int
    var date: Date?
    var total_price: Double
    var amount: Double
    var fees: Double
    var discount: Double
    var id_seller: String
    var id_session: Int
    var unitary_price: Double
    var games_deposited: [GamesDeposited]
    
    var id: String { id_deposit }
}
