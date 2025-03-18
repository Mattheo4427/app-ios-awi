//
//  ClientViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import Foundation

@MainActor
class ClientViewModel: ObservableObject {
    @Published var clients: [Client] = []
    private let endpoint = "clients/"

    // Fetch all clients
    func fetchClients() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedClients: [Client] = decodeJSON(from: data, as: [Client].self) {
                self.clients = fetchedClients
            }
        } catch {
            print("Erreur récupération clients:", error)
        }
    }

    // Create a new client
    func createClient(client: Client) async {
        do {
            let body = try JSONEncoder().encode(client)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newClient: Client = decodeJSON(from: data, as: Client.self) {
                self.clients.append(newClient) // Add new client to list
            }
        } catch {
            print("Erreur création client:", error)
        }
    }

    // Update an existing client
    func updateClient(client: Client) async {
        do {
            let body = try JSONEncoder().encode(client)
            let data = try await fetchData(from: "\(endpoint)/\(client.id_client)", reqMethod: "PUT", body: body)
            
            if let updatedClient: Client = decodeJSON(from: data, as: Client.self) {
                if let index = self.clients.firstIndex(where: { $0.id_client == updatedClient.id_client }) {
                    self.clients[index] = updatedClient // Update local list
                }
            }
        } catch {
            print("Error modification client:", error)
        }
    }

    // Delete a client
    func deleteClient(clientID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)/\(clientID)", reqMethod: "DELETE")
            self.clients.removeAll { $0.id_client == clientID } // Remove from local list
        } catch {
            print("Error suppression client:", error)
        }
    }
}
