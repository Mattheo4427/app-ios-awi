//
//  UpdateGameView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    @State var game: Game

    @State private var name = ""
    @State private var descriptionText = ""
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
            TextField("Description", text: $descriptionText)
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
            
            Button("Modifier Jeu") {
                Task {
                    let updatedGame = Game(
                        id_game: game.id_game,
                        name: name,
                        description: descriptionText.isEmpty ? nil : descriptionText,
                        image: image.isEmpty ? nil : image,
                        min_players: Int(minPlayers) ?? 0,
                        max_players: Int(maxPlayers) ?? 0,
                        min_age: Int(minAge) ?? 0,
                        max_age: Int(maxAge) ?? 0,
                        id_editor: Int(idEditor) ?? 0,
                        id_category: Int(idCategory) ?? 0
                    )
                    await viewModel.updateGame(game: updatedGame)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Jeu")
        .onAppear {
            name = game.name
            descriptionText = game.description ?? ""
            image = game.image ?? ""
            minPlayers = "\(game.min_players)"
            maxPlayers = "\(game.max_players)"
            minAge = "\(game.min_age)"
            maxAge = "\(game.max_age)"
            idEditor = "\(game.id_editor)"
            idCategory = "\(game.id_category)"
        }
    }
}