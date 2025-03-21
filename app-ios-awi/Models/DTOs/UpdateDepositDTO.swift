//
//  UpdateDepositDTO.swift
//  app-ios-awi
//
//  Created by etud on 21/03/2025.
//

import Foundation

struct UpdateDepositDto: Codable {
    let id_deposit: String
    let date: Date
    let amount: Double
    let fees: Double
    let discount: Double
    let id_seller: String
    let id_session: Int
    let games_deposited: [GameDepositedDto]
}
