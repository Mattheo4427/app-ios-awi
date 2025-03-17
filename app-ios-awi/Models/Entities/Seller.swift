//
//  Seller.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

struct Seller: Identifiable, Codable {
    let id_seller: String
    var username: String
    var email: String
    var password: String
    var firstname: String
    var lastname: String
    var phone: String?
    var address: String?

    var id: String { id_seller }
}
