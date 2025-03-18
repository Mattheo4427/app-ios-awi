//
//  Game.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct Game: Identifiable, Codable {
    let id_game: Int
    var name: String
    var description: String?
    var image: String?
    var min_players: Int
    var max_players: Int
    var min_age: Int
    var max_age: Int
    var id_editor: Int
    var id_category: Int

    var id: Int { id_game }
}
