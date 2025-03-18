//
//  Sale.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct GameSold: Codable, Identifiable {
    let id = UUID()
    var id_game: Int
    var tags: [String]?
    var quantity: Int
}

struct Sale: Identifiable, Codable {
    var id_sale: String
    var date: Date?
    var amount: Double
    var comission: Double
    var payment_method: String
    var id_seller: String
    var id_client: Int
    var id_session: Int
    var id_game: Int
    var quantity: Int
    var games_sold: [GameSold]
    
    var id: String { id_sale }
}
