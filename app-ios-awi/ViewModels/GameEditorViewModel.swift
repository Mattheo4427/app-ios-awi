//
//  GameEditorViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.

import Foundation

@MainActor
class GameEditorViewModel: ObservableObject {
    @Published var gameEditors: [GameEditor] = []
    private let endpoint = "game-editor/"

    // Fetch all game editors
    func fetchGameEditors() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedEditors: [GameEditor] = decodeJSON(from: data, as: [GameEditor].self) {
                self.gameEditors = fetchedEditors
            }
        } catch {
            print("Erreur récupération éditeurs:", error)
        }
    }

    // Create a new game editor
    func createGameEditor(editor: GameEditor) async {
        do {
            let body = try JSONEncoder().encode(editor)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newEditor: GameEditor = decodeJSON(from: data, as: GameEditor.self) {
                self.gameEditors.append(newEditor)
            }
        } catch {
            print("Erreur création éditeur:", error)
        }
    }

    // Update an existing game editor
    func updateGameEditor(editor: GameEditor) async {
        do {
            let body = try JSONEncoder().encode(editor)
            let data = try await fetchData(from: "\(endpoint)\(editor.id_editor)", reqMethod: "PUT", body: body)
            
            if let updatedEditor: GameEditor = decodeJSON(from: data, as: GameEditor.self) {
                if let index = self.gameEditors.firstIndex(where: { $0.id_editor == updatedEditor.id_editor }) {
                    self.gameEditors[index] = updatedEditor
                }
            }
        } catch {
            print("Erreur modification éditeur:", error)
        }
    }

    // Delete a game editor
    func deleteGameEditor(editorID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(editorID)", reqMethod: "DELETE")
            self.gameEditors.removeAll { $0.id_editor == editorID }
        } catch {
            print("Erreur suppression éditeur:", error)
        }
    }
}
