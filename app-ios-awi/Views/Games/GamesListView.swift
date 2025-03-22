//
//  GamesListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct GamesListView: View {
    @StateObject var viewModel = GameViewModel()
    @StateObject private var editorViewModel = GameEditorViewModel()
    @StateObject private var categoryViewModel = GameCategoryViewModel()
    @State private var showDeleteAlert = false
    @State private var gameToDelete: Int?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.games.isEmpty {
                    VStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun jeu trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucun jeu enregistré.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.games) { game in
                            NavigationLink(destination: UpdateGameView(viewModel: viewModel, game: game)) {
                                HStack {
                                    AsyncImage(url: URL(string: game.image ?? "")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 60, height: 60)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        case .failure:
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                                .frame(width: 60, height: 60)
                                        @unknown default:
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                                .frame(width: 60, height: 60)
                                        }
                                    }
                                    .frame(width: 60, height: 60)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(game.name)
                                            .font(.headline)
                                        
                                        HStack(spacing: 12) {
                                            Text("👥 \(game.min_players)-\(game.max_players)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text("📅 \(game.min_age)-\(game.max_age) ans")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        if let editor = editorViewModel.gameEditors.first(where: { $0.id_editor == game.id_editor }) {
                                            Text("🏢 \(editor.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        if let category = categoryViewModel.gameCategories.first(where: { $0.id_category == game.id_category }) {
                                            Text("🏷️ \(category.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                        
                                        if let description = game.description {
                                            Text(description)
                                                .lineLimit(2)
                                                .truncationMode(.tail)
                                                .font(.subheadline)
                                        }
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: confirmDelete)
                    }
                }
            }
            .navigationTitle("Jeux")
            .toolbar {
                NavigationLink(destination: CreateGameView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                // Fetch all necessary data
                await viewModel.fetchGames()
                await editorViewModel.fetchGameEditors()
                await categoryViewModel.fetchGameCategories()
            }
            .refreshable {
                // Add refreshable support
                await viewModel.fetchGames()
                await editorViewModel.fetchGameEditors()
                await categoryViewModel.fetchGameCategories()
            }
            .alert("Supprimer le jeu", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let gameID = gameToDelete {
                        Task {
                            await viewModel.deleteGame(gameID: gameID)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer ce jeu ? Cette action est irréversible.")
            }
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
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            gameToDelete = viewModel.games[index].id_game
            showDeleteAlert = true
        }
    }
}