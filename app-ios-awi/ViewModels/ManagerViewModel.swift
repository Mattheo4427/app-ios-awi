//
// ManagerViewModel.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import Foundation

@MainActor
class ManagerViewModel: ObservableObject {
    @Published var managers: [Manager] = []
    private let endpoint = "managers"

    // Fetch all managers
    func fetchManagers() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedManagers: [Manager] = decodeJSON(from: data, as: [Manager].self) {
                self.managers = fetchedManagers
            }
        } catch {
            print("Erreur récupération managers:", error)
        }
    }

    // Create a new manager
    func createManager(manager: Manager) async {
        do {
            let body = try JSONEncoder().encode(manager)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newManager: Manager = decodeJSON(from: data, as: Manager.self) {
                self.managers.append(newManager) // Add new manager to list
            }
        } catch {
            print("Erreur création manager:", error)
        }
    }

    // Update an existing manager
    func updateManager(manager: Manager) async {
        do {
            let body = try JSONEncoder().encode(manager)
            let data = try await fetchData(from: "\(endpoint)/\(manager.id_manager)", reqMethod: "PUT", body: body)
            
            if let updatedManager: Manager = decodeJSON(from: data, as: Manager.self) {
                if let index = self.managers.firstIndex(where: { $0.id_manager == updatedManager.id_manager }) {
                    self.managers[index] = updatedManager // Update local list
                }
            }
        } catch {
            print("Erreur modification manager:", error)
        }
    }

    // Delete a manager
    func deleteManager(managerID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)/\(managerID)", reqMethod: "DELETE")
            self.managers.removeAll { $0.id_manager == managerID } // Remove from local list
        } catch {
            print("Erreur suppression manager:", error)
        }
    }
}
