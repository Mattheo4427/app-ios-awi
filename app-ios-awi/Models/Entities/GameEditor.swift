//
//  GameEditor.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

struct GameEditor: Identifiable, Codable {
    let id_editor: Int
    var name: String
    var description: String?

    var id: Int { id_editor }
}
