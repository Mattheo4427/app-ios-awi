//
//  GameCategory.swift
//  app-ios-awi
//
//  Created by Deniel Hedbaut on 17/03/2025.
//

import Foundation

struct GameCategory: Identifiable, Codable {
    let tag: String
    let name: String
    let description: String
    
    var id: String { tag }
}
