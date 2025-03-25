//
//  HomeViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var depositedGames: [DepositedGame] = []
    @Published var mergedGames: [MergedGame] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isManager = false {
        didSet {
            // Re-merge games when manager status changes
            if oldValue != isManager {
                mergeGames()
            }
        }
    }
    @Published var allDepositedGames: [DepositedGame] = []

    @AppStorage("authToken") private var authToken = ""
    
    // Modify the fetchCatalogue function to better handle game details loading
    func fetchCatalogue() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch deposited games
            if let data = try await fetchData(from: "deposited-game") {
                if let games = decodeJSON(from: data, as: [DepositedGame].self) {
                    self.allDepositedGames = games // Store all games
                    
                    // If manager, show all games; otherwise, only show for sale games
                    if isManager {
                        self.depositedGames = games
                    } else {
                        self.depositedGames = games.filter { $0.forSale == true && !$0.sold }
                    }
                    
                    // Merge games with same seller, price, and game ID
                    mergeGames()
                    
                    // Fetch details for each unique game
                    await fetchGameDetails()
                    
                    // Check if we have empty results after filtering
                    if self.depositedGames.isEmpty && errorMessage == nil {
                        errorMessage = "Aucun jeu disponible dans le catalogue."
                    }
                } else {
                    errorMessage = "Impossible de décoder les jeux."
                }
            } else {
                errorMessage = "Aucune donnée reçue pour les jeux."
            }
        } catch {
            errorMessage = "Erreur réseau: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    // Improve the fetchGameDetails function to be more robust
    func fetchGameDetails() async {
        // Get unique game IDs from merged games
        let uniqueGameIds = Set(mergedGames.map { $0.gameId })
        
        var updatedGameDetails: [(gameId: Int, details: Game)] = []
        
        // Create a task group to fetch details concurrently
        await withTaskGroup(of: (Int, Game?).self) { group in
            // Add tasks for each game ID
            for gameId in uniqueGameIds {
                group.addTask {
                    // Try up to 3 times to fetch game details
                    for attempt in 1...3 {
                        do {
                            if let data = try await fetchData(from: "game/\(gameId)") {
                                if let game = decodeJSON(from: data, as: Game.self) {
                                    return (gameId, game)
                                }
                            }
                            
                            // If we didn't succeed, wait briefly before retrying
                            if attempt < 3 {
                                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
                            }
                        } catch {
                            print("Error fetching details for game \(gameId) (attempt \(attempt)): \(error.localizedDescription)")
                            
                            // If this was the last attempt, log a more serious warning
                            if attempt == 3 {
                                print("FAILED to load game \(gameId) after 3 attempts")
                            }
                        }
                    }
                    return (gameId, nil) // Return nil if all attempts failed
                }
            }
            
            // Process results as they come in
            for await (gameId, gameDetails) in group {
                if let gameDetails = gameDetails {
                    // Store the results to update all at once later
                    updatedGameDetails.append((gameId: gameId, details: gameDetails))
                }
            }
        }
        
        // Now update the UI state with all collected results
        // This avoids actor-isolation issues
        for (gameId, details) in updatedGameDetails {
            for index in mergedGames.indices {
                if mergedGames[index].gameId == gameId {
                    mergedGames[index].gameDetails = details
                }
            }
        }
        
        // Ensure loading state is set to false
        isLoading = false
    }
        
    private func mergeGames() {
        // For managers, decide which source of games to use
        let gamesToMerge = isManager ? allDepositedGames : depositedGames
        
        // Group games by game ID, seller ID, and price
        let groupedGames = Dictionary(grouping: gamesToMerge) { game in
            return "\(game.id_game)-\(game.idSeller)-\(game.price)"
        }
        
        // Create merged games with counts
        mergedGames = groupedGames.map { (_, games) in
            let firstGame = games.first!
            return MergedGame(
                gameId: firstGame.id_game,
                price: firstGame.price,
                sellerId: firstGame.idSeller,
                count: games.count
            )
        }.sorted { $0.gameId < $1.gameId }
    }

    // Toggle a game's forSale status
    func toggleForSaleStatus(for game: DepositedGame) async -> Bool {
        isLoading = true
        
        // Create updated game object with only the necessary fields
        // Make sure to convert price to a number since it's expected as @IsNumber()
        let updatedGame: [String: Any] = [
            "price": Double(game.price) ?? 0.0,  // Convert string price to Double
            "for_sale": !game.forSale,           // Toggle the for_sale status
            "sold": game.sold,                   // Keep existing sold status
            "id_game": game.id_game,             // Keep game ID
            "id_session": game.idSession,        // Keep session ID
            "id_seller": game.idSeller           // Keep seller ID
        ]
        
        do {
            // Convert to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: updatedGame)
            
            // Send PUT request
            if let _ = try await fetchData(from: "deposited-game/\(game.tag)", reqMethod: "PUT", body: jsonData, token: authToken) {
                // Refresh catalogue to get updated data
                await fetchCatalogue()
                isLoading = false
                return true
            }
        } catch {
            print("Error updating game status: \(error.localizedDescription)")
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isLoading = false
        return false
    }

    func findGameDetails(for gameId: Int) -> Game? {
        // Look through merged games for game details
        for mergedGame in mergedGames where mergedGame.gameId == gameId {
            if let details = mergedGame.gameDetails {
                return details
            }
        }
        return nil
    }
}
