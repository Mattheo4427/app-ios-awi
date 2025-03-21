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
    @StateObject private var editorViewModel = GameEditorViewModel()
    @StateObject private var categoryViewModel = GameCategoryViewModel()

    @State private var name = ""
    @State private var description = ""
    @State private var image = ""
    @State private var minPlayers = ""
    @State private var maxPlayers = ""
    @State private var minAge = ""
    @State private var maxAge = ""
    @State private var selectedEditor: GameEditor?
    @State private var selectedCategory: GameCategory?

    var body: some View {
        Form {
            // Name section
            Section {
                VStack(alignment: .leading) {
                    Text("Nom du jeu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $name)
                }
            }
            
            // Description section
            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Media section
            Section(header: Text("Média")) {
                TextField("Image URL", text: $image)
            }
            
            // Players section
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

            // Age section
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
            
            // References section
            Section(header: Text("Références")) {
                // Editor picker
                VStack(alignment: .leading) {
                    Text("Éditeur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if editorViewModel.gameEditors.isEmpty {
                        Text("Chargement des éditeurs...")
                            .foregroundColor(.gray)
                    } else {
                        Menu {
                            ForEach(editorViewModel.gameEditors) { editor in
                                Button(editor.name) {
                                    selectedEditor = editor
                                }
                            }
                        } label: {
                            Text(selectedEditor?.name ?? "Sélectionner un éditeur")
                                .foregroundColor(selectedEditor == nil ? .gray : .primary)
                        }
                    }
                }
                
                // Category picker
                VStack(alignment: .leading) {
                    Text("Catégorie")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if categoryViewModel.gameCategories.isEmpty {
                        Text("Chargement des catégories...")
                            .foregroundColor(.gray)
                    } else {
                        Menu {
                            ForEach(categoryViewModel.gameCategories) { category in
                                Button(category.name) {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            Text(selectedCategory?.name ?? "Sélectionner une catégorie")
                                .foregroundColor(selectedCategory == nil ? .gray : .primary)
                        }
                    }
                }
            }

            // Create button section
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
                            id_editor: selectedEditor?.id_editor ?? 0,
                            id_category: selectedCategory?.id_category ?? 0
                        )
                        await viewModel.createGame(game: newGame)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(selectedEditor == nil || selectedCategory == nil)
            }
        }
        .navigationTitle("Nouveau Jeu")
        .alert(
            "Erreur",
            isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil || editorViewModel.errorMessage != nil || categoryViewModel.errorMessage != nil },
                set: { if !$0 { 
                    viewModel.dismissError()
                    editorViewModel.dismissError()
                    categoryViewModel.dismissError()
                }}
            ),
            actions: { Button("OK", role: .cancel) {} },
            message: { 
                if let error = viewModel.errorMessage {
                    Text(error)
                } else if let error = editorViewModel.errorMessage {
                    Text(error)
                } else {
                    Text(categoryViewModel.errorMessage ?? "")
                }
            }
        )
        .onAppear {
            Task {
                await editorViewModel.fetchGameEditors()
                await categoryViewModel.fetchGameCategories()
            }
        }
    }
}