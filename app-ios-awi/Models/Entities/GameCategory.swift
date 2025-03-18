//
//  GameCategory.swift
//  app-ios-awi
//
//  Created by Deniel Hedbaut on 17/03/2025.
//

import Foundation

struct GameCategory: Identifiable, Codable {
    let id_category: Int
    var name: String
    var description: String?

    var id: Int { id_category }
}
