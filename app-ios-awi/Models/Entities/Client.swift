//
//  Client.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

struct Client: Identifiable, Codable {
    let id_client: Int
    var firstname: String
    var lastname: String
    var email: String
    var phone: String
    var address: String?

    var id: Int { id_client }
}
