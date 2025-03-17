//
//  HomeViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var games: [DepositedGame] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let apiURL = ""
    
    func fetchGames() async {
        // Set loading state to true, this needs to be on the main thread
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            // Fetch data asynchronously
            if let data = try await fetchData(from: apiURL), let decodedGames: [DepositedGame] = decodeJSON(from: data, as: [DepositedGame].self) {
                // Set the games data on the main thread
                DispatchQueue.main.async {
                    self.games = decodedGames
                }
            } else {
                // Handle the error message on the main thread
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load games."
                }
            }
        } catch {
            // Handle any errors on the main thread
            DispatchQueue.main.async {
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
        
        // Set loading state to false on the main thread after fetching
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
