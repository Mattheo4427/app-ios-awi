//
//  HomeViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var depositedGames: [DepositedGame] = []
    @Published var mergedGames: [MergedGame] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchCatalogue() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch deposited games
            if let data = try await fetchData(from: "deposited-game") {
                if let games = decodeJSON(from: data, as: [DepositedGame].self) {
                    self.depositedGames = games
                    // Merge games with same seller, price, and game ID
                    mergeGames()
                    // Fetch details for each unique game
                    await fetchGameDetails()
                } else {
                    errorMessage = "Impossible de décoder les jeux."
                }
            } else {
                errorMessage = "Aucune donnée reçue pour les jeux."
            }
            
            // Display error if no games are available
            if self.depositedGames.isEmpty && errorMessage == nil {
                errorMessage = "Aucun jeu disponible dans le catalogue."
            }
        } catch {
            errorMessage = "Erreur réseau: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func mergeGames() {
        // Group games by game ID, seller ID, and price
        let groupedGames = Dictionary(grouping: depositedGames) { game in
            return "\(game.idGame)-\(game.idSeller)-\(game.price)"
        }
        
        // Create merged games with counts
        mergedGames = groupedGames.map { (_, games) in
            let firstGame = games.first!
            return MergedGame(
                gameId: firstGame.idGame,
                price: firstGame.price,
                sellerId: firstGame.idSeller,
                count: games.count
            )
        }.sorted { $0.gameId < $1.gameId }
    }
    
    func fetchGameDetails() async {
        // Get unique game IDs from deposited games
        let uniqueGameIds = Set(mergedGames.map { $0.gameId })
        
        // Fetch details for each unique game
        for gameId in uniqueGameIds {
            do {
                if let data = try await fetchData(from: "game/\(gameId)") {
                    if let game = decodeJSON(from: data, as: Game.self) {
                        // Update merged games with the corresponding game details
                        for index in mergedGames.indices {
                            if mergedGames[index].gameId == gameId {
                                mergedGames[index].gameDetails = game
                            }
                        }
                    }
                }
            } catch {
                print("Error fetching details for game \(gameId): \(error.localizedDescription)")
            }
        }
    }
}