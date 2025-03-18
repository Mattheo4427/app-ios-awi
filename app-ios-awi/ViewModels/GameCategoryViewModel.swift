//
//  GameCategoryViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation

@MainActor
class GameCategoryViewModel: ObservableObject {
    @Published var gameCategories: [GameCategory] = []
    private let endpoint = "game-category/"

    // Fetch all game categories
    func fetchGameCategories() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedCategories: [GameCategory] = decodeJSON(from: data, as: [GameCategory].self) {
                self.gameCategories = fetchedCategories
            }
        } catch {
            print("Erreur récupération catégories:", error)
        }
    }

    // Create a new game category
    func createGameCategory(category: GameCategory) async {
        do {
            let body = try JSONEncoder().encode(category)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newCategory: GameCategory = decodeJSON(from: data, as: GameCategory.self) {
                self.gameCategories.append(newCategory)
            }
        } catch {
            print("Erreur création catégorie:", error)
        }
    }

    // Update an existing game category
    func updateGameCategory(category: GameCategory) async {
        do {
            let body = try JSONEncoder().encode(category)
            let data = try await fetchData(from: "\(endpoint)\(category.id_category)", reqMethod: "PUT", body: body)
            
            if let updatedCategory: GameCategory = decodeJSON(from: data, as: GameCategory.self) {
                if let index = self.gameCategories.firstIndex(where: { $0.id_category == updatedCategory.id_category }) {
                    self.gameCategories[index] = updatedCategory
                }
            }
        } catch {
            print("Erreur modification catégorie:", error)
        }
    }

    // Delete a game category
    func deleteGameCategory(categoryID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(categoryID)", reqMethod: "DELETE")
            self.gameCategories.removeAll { $0.id_category == categoryID }
        } catch {
            print("Erreur suppression catégorie:", error)
        }
    }
}
