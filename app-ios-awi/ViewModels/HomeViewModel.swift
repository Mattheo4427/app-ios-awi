//
//  HomeViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var games: [DepositedGame] = []
    @Published var categories: [GameCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCatalogue() async {
        isLoading = true
        errorMessage = nil

        async let gamesData = fetchData(from: "deposited-game")
        async let categoriesData = fetchData(from: "game-category")

        do {
            games = decodeJSON(from: try await gamesData, as: [DepositedGame].self) ?? []
        } catch {
            errorMessage = "Impossible de charger le catalogue."
        }

        isLoading = false
    }
}
