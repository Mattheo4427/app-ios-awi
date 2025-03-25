//
//  GameModels.swift
//  app-ios-awi
//

import Foundation

struct DepositedGame: Identifiable, Decodable {
    var id: String { tag }
    let tag: String
    let price: String
    let sold: Bool
    let forSale: Bool
    let idSession: Int
    let idSeller: String
    let id_game: Int
    
    enum CodingKeys: String, CodingKey {
        case tag, price, sold
        case forSale = "for_sale"
        case idSession = "id_session"
        case idSeller = "id_seller"
        case id_game = "id_game"
    }
}

struct MergedGame: Identifiable {
    let id = UUID()
    let gameId: Int
    let price: String
    let sellerId: String
    let count: Int
    var gameDetails: Game?
}
