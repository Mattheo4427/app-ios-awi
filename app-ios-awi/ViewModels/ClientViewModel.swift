//
//  ClientViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class ClientViewModel: ObservableObject {
    @Published var clients: [Client] = []
    private let endpoint = "clients/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil

    // Fetch all clients
    func fetchClients() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedClients: [Client] = decodeJSON(from: data, as: [Client].self) {
                self.clients = fetchedClients
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new client
    func createClient(client: Client) async {
        do {
            let body = try JSONEncoder().encode(client)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newClient: Client = decodeJSON(from: data, as: Client.self) {
                self.clients.append(newClient)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing client
    func updateClient(client: Client) async {
        do {
            let body = try JSONEncoder().encode(client)
            let data = try await fetchData(from: "\(endpoint)update/\(client.id_client)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedClient: Client = decodeJSON(from: data, as: Client.self) {
                if let index = self.clients.firstIndex(where: { $0.id_client == updatedClient.id_client }) {
                    self.clients[index] = updatedClient
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a client
    func deleteClient(clientID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(clientID)", reqMethod: "DELETE", token: authToken)
            self.clients.removeAll { $0.id_client == clientID }
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