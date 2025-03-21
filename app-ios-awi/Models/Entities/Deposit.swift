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
    
    // Use this initializer if needed when creating a deposit locally.
    init(id_seller: String, id_session: Int, date: Date, amount: Double, fees: Double, discount: Double, games_deposited: [GameDeposited]) {
        self.id_deposit = UUID().uuidString
        self.id_game = 0
        self.quantity = 0
        self.date = date
        self.total_price = 0
        self.amount = amount
        self.fees = fees
        self.discount = discount
        self.id_seller = id_seller
        self.id_session = id_session
        self.unitary_price = 0
        self.games_deposited = games_deposited
    }
    
    // Custom decoding initializer that assigns default values when keys are missing.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id_deposit = try container.decode(String.self, forKey: .id_deposit)
        date = try container.decode(Date.self, forKey: .date)
        id_seller = try container.decode(String.self, forKey: .id_seller)
        id_session = try container.decode(Int.self, forKey: .id_session)
        
        // Handle amount conversion (it might be sent as a string).
        if let amountStr = try? container.decode(String.self, forKey: .amount),
           let amountDouble = Double(amountStr) {
            amount = amountDouble
        } else {
            amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0
        }
        
        if let feesStr = try? container.decode(String.self, forKey: .fees),
           let feesDouble = Double(feesStr) {
            fees = feesDouble
        } else {
            fees = try container.decodeIfPresent(Double.self, forKey: .fees) ?? 0
        }
        
        if let discountStr = try? container.decode(String.self, forKey: .discount),
           let discountDouble = Double(discountStr) {
            discount = discountDouble
        } else {
            discount = try container.decodeIfPresent(Double.self, forKey: .discount) ?? 0
        }
        
        // These keys might be missing in the response; default them to 0 or an empty array.
        id_game = try container.decodeIfPresent(Int.self, forKey: .id_game) ?? 0
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 0
        total_price = try container.decodeIfPresent(Double.self, forKey: .total_price) ?? 0
        unitary_price = try container.decodeIfPresent(Double.self, forKey: .unitary_price) ?? 0
        games_deposited = try container.decodeIfPresent([GameDeposited].self, forKey: .games_deposited) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case id_deposit, id_game, quantity, date, total_price, amount, fees, discount, id_seller, id_session, unitary_price, games_deposited
    }
}

struct GameDeposited: Codable, Identifiable {
    let id_game: Int
    var quantity: Int
    var price: Double
    var nb_for_sale: Int
    
    var id: Int { id_game }
}
