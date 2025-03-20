//
//  GameCategoryViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation
import SwiftUI

@MainActor
class GameCategoryViewModel: ObservableObject {
    @Published var gameCategories: [GameCategory] = []
    private let endpoint = "game-category/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil

    // Fetch all game categories
    func fetchGameCategories() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            if let fetchedCategories: [GameCategory] = decodeJSON(from: data, as: [GameCategory].self) {
                self.gameCategories = fetchedCategories
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new game category
    func createGameCategory(category: GameCategory) async {
        do {
            let body = try JSONEncoder().encode(category)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newCategory: GameCategory = decodeJSON(from: data, as: GameCategory.self) {
                self.gameCategories.append(newCategory)
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing game category
    func updateGameCategory(category: GameCategory) async {
        do {
            let body = try JSONEncoder().encode(category)
            let data = try await fetchData(from: "\(endpoint)\(category.id_category)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedCategory: GameCategory = decodeJSON(from: data, as: GameCategory.self) {
                if let index = self.gameCategories.firstIndex(where: { $0.id_category == updatedCategory.id_category }) {
                    self.gameCategories[index] = updatedCategory
                }
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a game category
    func deleteGameCategory(categoryID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(categoryID)", reqMethod: "DELETE", token: authToken)
            self.gameCategories.removeAll { $0.id_category == categoryID }
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
    
    func dismissError() {
        self.errorMessage = nil
    }
}
