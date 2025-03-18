//
//  CreateGameView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var image = ""
    @State private var minPlayers = ""
    @State private var maxPlayers = ""
    @State private var minAge = ""
    @State private var maxAge = ""
    @State private var idEditor = ""
    @State private var idCategory = ""

    var body: some View {
        Form {
            TextField("Nom", text: $name)
            TextField("Description", text: $description)
            TextField("Image URL", text: $image)
            TextField("Min Players", text: $minPlayers)
                .keyboardType(.numberPad)
            TextField("Max Players", text: $maxPlayers)
                .keyboardType(.numberPad)
            TextField("Min Age", text: $minAge)
                .keyboardType(.numberPad)
            TextField("Max Age", text: $maxAge)
                .keyboardType(.numberPad)
            TextField("ID Editeur", text: $idEditor)
                .keyboardType(.numberPad)
            TextField("ID Catégorie", text: $idCategory)
                .keyboardType(.numberPad)
            
            Button("Créer Jeu") {
                Task {
                    let newGame = Game(
                        id_game: Int.random(in: 1000...9999), // Temporary ID
                        name: name,
                        description: description.isEmpty ? nil : description,
                        image: image.isEmpty ? nil : image,
                        min_players: Int(minPlayers) ?? 0,
                        max_players: Int(maxPlayers) ?? 0,
                        min_age: Int(minAge) ?? 0,
                        max_age: Int(maxAge) ?? 0,
                        id_editor: Int(idEditor) ?? 0,
                        id_category: Int(idCategory) ?? 0
                    )
                    await viewModel.createGame(game: newGame)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouveau Jeu")
    }
}