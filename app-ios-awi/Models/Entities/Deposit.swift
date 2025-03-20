//
//  Deposit.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct Deposit: Identifiable, Codable {
    let id_deposit: String
    var id_game: Int
    var quantity: Int
    var date: Date
    var total_price: Double
    var amount: Double
    var fees: Double       // to be updated from backend if needed
    var discount: Double   // to be updated from backend if needed
    var id_seller: String
    var id_session: Int
    var unitary_price: Double
    var games_deposited: [GameDeposited]
    
    var id: String { id_deposit }
    
    // Custom initializer using only the required fields
    init(id_seller: String, id_game: Int, quantity: Int, unitary_price: Double) {
        self.id_deposit = UUID().uuidString
        self.id_seller = id_seller
        self.id_game = id_game
        self.quantity = quantity
        self.unitary_price = unitary_price
        self.date = Date()
        self.total_price = Double(quantity) * unitary_price
        self.amount = 0
        self.fees = 0
        self.discount = 0
        self.id_session = 0
        self.games_deposited = []
    }
}

struct GameDeposited: Codable, Identifiable {
    let id_game: Int
    var quantity: Int
    var price: Double
    var nb_for_sale: Int
    
    var id: Int { id_game }
}