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
            VStack(alignment: .leading) {
                Text("Nom du jeu")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Nom", text: $name)
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.vertical, 4)
            }
            
            Section(header: Text("Média")) {
                TextField("Image URL", text: $image)
            }
            
            Section(header: Text("Nombre de joueurs")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Minimum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Min", text: $minPlayers)
                            .keyboardType(.numberPad)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Maximum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Max", text: $maxPlayers)
                            .keyboardType(.numberPad)
                    }
                }
            }

            Section(header: Text("Âge recommandé")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Minimum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Min", text: $minAge)
                            .keyboardType(.numberPad)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Maximum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Max", text: $maxAge)
                            .keyboardType(.numberPad)
                    }
                }
            }
            
            Section(header: Text("Références")) {
                TextField("ID Editeur", text: $idEditor)
                    .keyboardType(.numberPad)
                TextField("ID Catégorie", text: $idCategory)
                    .keyboardType(.numberPad)
            }
            
            Section {
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
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Nouveau Jeu")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}