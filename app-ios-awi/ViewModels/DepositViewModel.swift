//
//  DepositViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class DepositViewModel: ObservableObject {
    @Published var deposits: [Deposit] = []
    private let endpoint = "deposits/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil
    
    func fetchDeposits() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedDeposits: [Deposit] = decodeJSON(from: data, as: [Deposit].self) {
                self.deposits = fetchedDeposits
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func createDeposit(deposit: Deposit) async {
        do {
            let body = try JSONEncoder().encode(deposit)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newDeposit: Deposit = decodeJSON(from: data, as: Deposit.self) {
                self.deposits.append(newDeposit)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func updateDeposit(deposit: Deposit) async {
        do {
            let body = try JSONEncoder().encode(deposit)
            let data = try await fetchData(from: "\(endpoint)update/\(deposit.id_deposit)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedDeposit: Deposit = decodeJSON(from: data, as: Deposit.self) {
                if let index = self.deposits.firstIndex(where: { $0.id_deposit == updatedDeposit.id_deposit }) {
                    self.deposits[index] = updatedDeposit
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func deleteDeposit(depositID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(depositID)", reqMethod: "DELETE", token: authToken)
            self.deposits.removeAll { $0.id_deposit == depositID }
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
}
