//
//  Manager.swift
//  app-ios-awi
//
//  Created by etud on 15/03/2025.
//

import Foundation

struct Manager: Identifiable, Codable {
    let id_manager: String
    var username: String
    var email: String
    var password: String
    var firstname: String
    var lastname: String
    var phone: String
    var address: String?
    var is_admin: Bool

    var id: String { id_manager }
}
