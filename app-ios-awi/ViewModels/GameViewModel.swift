//
//  GameViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation

@MainActor
class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    private let endpoint = "game/"

    // Fetch all games
    func fetchGames() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedGames: [Game] = decodeJSON(from: data, as: [Game].self) {
                self.games = fetchedGames
            }
        } catch {
            print("Erreur récupération jeux:", error)
        }
    }

    // Create a new game
    func createGame(game: Game) async {
        do {
            let body = try JSONEncoder().encode(game)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newGame: Game = decodeJSON(from: data, as: Game.self) {
                self.games.append(newGame) // Add new game to list
            }
        } catch {
            print("Erreur création jeu:", error)
        }
    }

    // Update an existing game
    func updateGame(game: Game) async {
        do {
            let body = try JSONEncoder().encode(game)
            let data = try await fetchData(from: "\(endpoint)\(game.id_game)", reqMethod: "PUT", body: body)

            if let updatedGame: Game = decodeJSON(from: data, as: Game.self) {
                if let index = self.games.firstIndex(where: { $0.id_game == updatedGame.id_game }) {
                    self.games[index] = updatedGame // Update local list
                }
            }
        } catch {
            print("Erreur modification jeu:", error)
        }
    }

    // Delete a game
    func deleteGame(gameID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(gameID)", reqMethod: "DELETE")
            self.games.removeAll { $0.id_game == gameID } // Remove from local list
        } catch {
            print("Erreur suppression jeu:", error)
        }
    }
}
