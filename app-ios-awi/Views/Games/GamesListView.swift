//
//  GamesListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct GamesListView: View {
    @StateObject var viewModel = GameViewModel()
    
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
                                VStack(alignment: .leading) {
                                    Text(game.name)
                                        .font(.headline)
                                    Text("Joueurs: \(game.min_players)-\(game.max_players)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteGame)
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
                await viewModel.fetchGames()
            }
        }
    }
    
    func deleteGame(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let gameID = viewModel.games[index].id_game
                await viewModel.deleteGame(gameID: gameID)
            }
        }
    }
}