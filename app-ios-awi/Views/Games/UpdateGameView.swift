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
            VStack(alignment: .leading) {
                Text("Nom du jeu")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Nom", text: $name)
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $descriptionText)
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
                VStack(alignment: .leading) {
                    Text("Éditeur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("ID Éditeur", text: $idEditor)
                        .keyboardType(.numberPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Catégorie")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("ID Catégorie", text: $idCategory)
                        .keyboardType(.numberPad)
                }
                .padding(.vertical, 4)
            }       
            
            Section {
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
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Modification Jeu")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
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