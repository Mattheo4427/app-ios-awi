//
//  Withdrawal.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct GamesWithdrawed: Codable, Identifiable {
    let id = UUID() // For SwiftUI List conformance
    var id_game: Int
    var quantity: Int
}

struct Withdrawal: Identifiable, Codable {
    let id_withdrawal: Int
    var date: Date?
    var amount: Double
    var id_deposited_game: String
    var id_seller: String
    var id_session: Int
    var games_withdrawed: [GamesWithdrawed]
    
    var id: Int { id_withdrawal }
}
