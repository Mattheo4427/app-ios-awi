//
//  HomeViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var games: [DepositedGame] = []
    @Published var categories: [GameCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCatalogue() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        async let gamesData = fetchData(from: "game")
        async let categoriesData = fetchData(from: "game-category")

        do {
            games = decodeJSON(from: try await gamesData, as: [DepositedGame].self) ?? []
            categories = decodeJSON(from: try await categoriesData, as: [GameCategory].self) ?? []
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Impossible de charger le catalogue."
            }
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
