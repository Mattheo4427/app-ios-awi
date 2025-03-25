//
//  GameViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    private let endpoint = "game/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil

    // Fetch all games
    func fetchGames() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            if let fetchedGames: [Game] = decodeJSON(from: data, as: [Game].self) {
                self.games = fetchedGames
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new game
    func createGame(game: Game) async {
        do {
            let body = try JSONEncoder().encode(game)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newGame: Game = decodeJSON(from: data, as: Game.self) {
                self.games.append(newGame) // Add new game to list
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing game
    func updateGame(game: Game) async {
        do {
            let body = try JSONEncoder().encode(game)
            let data = try await fetchData(from: "\(endpoint)\(game.id_game)", reqMethod: "PUT", body: body, token: authToken)

            if let updatedGame: Game = decodeJSON(from: data, as: Game.self) {
                if let index = self.games.firstIndex(where: { $0.id_game == updatedGame.id_game }) {
                    self.games[index] = updatedGame // Update local list
                }
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a game
    func deleteGame(gameID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(gameID)", reqMethod: "DELETE", token: authToken)
            self.games.removeAll { $0.id_game == gameID } // Remove from local list
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    // Centralized error handling
    private func handleError(_ error: NetworkError) {
        switch error {
        case .requestFailed(let statusCode, let message):
            if statusCode == 401 {
                self.errorMessage = "Authentification nécessaire"
            } else if let backendMessage = message, !backendMessage.isEmpty {
                // Use the backend's message directly
                self.errorMessage = backendMessage
            } else {
                self.errorMessage = "Erreur serveur (\(statusCode))"
            }
        case .invalidURL:
            self.errorMessage = "URL invalide"
        case .invalidMethod:
            self.errorMessage = "Méthode invalide"
        case .noData:
            self.errorMessage = "Aucune donnée reçue"
        case .decodingError(let message):
            self.errorMessage = "Erreur de décodage: \(message)"
        }
    }
}

extension GameViewModel {
    func dismissError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
}