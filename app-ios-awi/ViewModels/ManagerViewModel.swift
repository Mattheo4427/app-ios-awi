//
// ManagerViewModel.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import Foundation
import SwiftUI

@MainActor
class ManagerViewModel: ObservableObject {
    @Published var managers: [Manager] = []
    private let endpoint = "managers/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil

    // Fetch all managers
    func fetchManagers() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedManagers: [Manager] = decodeJSON(from: data, as: [Manager].self) {
                self.managers = fetchedManagers
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new manager
    func createManager(manager: Manager) async {
        do {
            let body = try JSONEncoder().encode(manager)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newManager: Manager = decodeJSON(from: data, as: Manager.self) {
                self.managers.append(newManager)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing manager
    func updateManager(manager: Manager) async {
        do {
            let body = try JSONEncoder().encode(manager)
            let data = try await fetchData(from: "\(endpoint)update/\(manager.id_manager)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedManager: Manager = decodeJSON(from: data, as: Manager.self) {
                if let index = self.managers.firstIndex(where: { $0.id_manager == updatedManager.id_manager }) {
                    self.managers[index] = updatedManager
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a manager
    func deleteManager(managerID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(managerID)", reqMethod: "DELETE", token: authToken)
            self.managers.removeAll { $0.id_manager == managerID }
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
        case .requestFailed(let statusCode):
            if statusCode == 401 {
                self.errorMessage = "Authentification nécessaire"
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
