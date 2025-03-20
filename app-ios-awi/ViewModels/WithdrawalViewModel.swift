//
//  WithdrawalViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class WithdrawalViewModel: ObservableObject {
    @Published var withdrawals: [Withdrawal] = []
    private let endpoint = "recovers/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil
    
    func fetchWithdrawals() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedWithdrawals: [Withdrawal] = decodeJSON(from: data, as: [Withdrawal].self) {
                self.withdrawals = fetchedWithdrawals
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func createWithdrawal(withdrawal: Withdrawal) async {
        do {
            let body = try JSONEncoder().encode(withdrawal)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newWithdrawal: Withdrawal = decodeJSON(from: data, as: Withdrawal.self) {
                self.withdrawals.append(newWithdrawal)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func updateWithdrawal(withdrawal: Withdrawal) async {
        do {
            let body = try JSONEncoder().encode(withdrawal)
            let data = try await fetchData(from: "\(endpoint)update/\(withdrawal.id_withdrawal)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedWithdrawal: Withdrawal = decodeJSON(from: data, as: Withdrawal.self) {
                if let index = self.withdrawals.firstIndex(where: { $0.id_withdrawal == updatedWithdrawal.id_withdrawal }) {
                    self.withdrawals[index] = updatedWithdrawal
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func deleteWithdrawal(withdrawalID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(withdrawalID)", reqMethod: "DELETE", token: authToken)
            self.withdrawals.removeAll { $0.id_withdrawal == withdrawalID }
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