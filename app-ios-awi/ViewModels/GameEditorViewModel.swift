//
//  GameEditorViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation
import SwiftUI

@MainActor
class GameEditorViewModel: ObservableObject {
    @Published var gameEditors: [GameEditor] = []
    private let endpoint = "game-editor/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil
    
    // Fetch all game editors
    func fetchGameEditors() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            if let fetchedEditors: [GameEditor] = decodeJSON(from: data, as: [GameEditor].self) {
                self.gameEditors = fetchedEditors
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new game editor
    func createGameEditor(editor: GameEditor) async {
        do {
            let body = try JSONEncoder().encode(editor)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newEditor: GameEditor = decodeJSON(from: data, as: GameEditor.self) {
                self.gameEditors.append(newEditor)
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing game editor
    func updateGameEditor(editor: GameEditor) async {
        do {
            let body = try JSONEncoder().encode(editor)
            let data = try await fetchData(from: "\(endpoint)\(editor.id_editor)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedEditor: GameEditor = decodeJSON(from: data, as: GameEditor.self) {
                if let index = self.gameEditors.firstIndex(where: { $0.id_editor == updatedEditor.id_editor }) {
                    self.gameEditors[index] = updatedEditor
                }
            }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a game editor
    func deleteGameEditor(editorID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(editorID)", reqMethod: "DELETE", token: authToken)
            self.gameEditors.removeAll { $0.id_editor == editorID }
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
