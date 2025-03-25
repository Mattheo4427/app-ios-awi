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
            guard let data = try await fetchData(from: endpoint, token: authToken) else {
                throw NetworkError.noData
            }
            
            // Define a manual decoding process for the response
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                var fetchedWithdrawals: [Withdrawal] = []
                
                for json in jsonArray {
                    if let idRecover = json["id_recover"] as? String,
                       let dateString = json["date"] as? String,
                       let amount = (json["amount"] as? String).flatMap({ Double($0) }) ?? (json["amount"] as? Double),
                       let idSeller = json["id_seller"] as? String,
                       let idSession = json["id_session"] as? Int {
                        
                        let dateFormatter = ISO8601DateFormatter()
                        dateFormatter.formatOptions = [.withInternetDateTime]
                        
                        let date = dateString.isEmpty ? Date() : (dateFormatter.date(from: dateString) ?? Date())

                        let idManager = json["id_manager"] as? String
                        
                        // For now, we'll create empty games array since the list endpoint might not include games
                        // We could fetch game details separately if needed
                        let withdrawal = Withdrawal(
                            id_recover: idRecover,
                            date: date,
                            amount: amount,
                            id_seller: idSeller,
                            id_session: idSession,
                            id_manager: idManager,
                            games_recovered: []
                        )
                        
                        fetchedWithdrawals.append(withdrawal)
                    }
                }
                
                self.withdrawals = fetchedWithdrawals
                self.errorMessage = nil
            } else {
                throw NetworkError.invalidMethod
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func createWithdrawal(withdrawal: Withdrawal) async throws {
        do {
            // Create a request object that matches what the API expects
            struct WithdrawalRequest: Codable {
                let amount: Double
                let id_seller: String
                let id_session: Int
                let games_recovered: [GamesWithdrawed]
                let id_withdrawal: Int?
            }
            
            let request = WithdrawalRequest(
                amount: withdrawal.amount,
                id_seller: withdrawal.id_seller,
                id_session: withdrawal.id_session,
                games_recovered: withdrawal.games_recovered,
                id_withdrawal: nil  // Let the server generate this
            )
            
            let body = try JSONEncoder().encode(request)
            
            guard let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken) else {
                throw NetworkError.noData
            }
            
            // The API returns a success message rather than the created object
            struct SuccessResponse: Codable {
                let data: String
            }
            
            if let _ = decodeJSON(from: data, as: SuccessResponse.self) {
                // Refresh the list to get the newly created withdrawal
                await fetchWithdrawals()
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
            throw networkError
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
            throw error
        }
    }
    
    func updateWithdrawal(withdrawal: Withdrawal) async {
        do {
            // Create a request object that matches what the API expects
            struct WithdrawalUpdateRequest: Codable {
                let amount: Double
                let id_seller: String
                let id_session: Int
                let games_recovered: [GamesWithdrawed]
            }
            
            let request = WithdrawalUpdateRequest(
                amount: withdrawal.amount,
                id_seller: withdrawal.id_seller,
                id_session: withdrawal.id_session,
                games_recovered: withdrawal.games_recovered
            )
            
            let body = try JSONEncoder().encode(request)
            
            guard let data = try await fetchData(from: "\(endpoint)update/\(withdrawal.id_recover)", reqMethod: "PUT", body: body, token: authToken) else {
                throw NetworkError.noData
            }
            
            // The API likely returns a success message rather than the updated object
            struct SuccessResponse: Codable {
                let data: String
            }
            
            if let _ = decodeJSON(from: data, as: SuccessResponse.self) {
                // Refresh the list to get the updated withdrawal
                await fetchWithdrawals()
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func deleteWithdrawal(withdrawalID: String) async {
        do {
            // Note the use of the String type for the ID
            guard let _ = try await fetchData(from: "\(endpoint)delete/\(withdrawalID)", reqMethod: "DELETE", token: authToken) else {
                throw NetworkError.noData
            }
            
            self.withdrawals.removeAll { $0.id_recover == withdrawalID }
            self.errorMessage = nil
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    // Fetch details for a specific withdrawal if needed
    func fetchWithdrawalDetails(withdrawalID: String) async {
        do {
            guard let data = try await fetchData(from: "\(endpoint)\(withdrawalID)", token: authToken) else {
                throw NetworkError.noData
            }
            
            if let withdrawal: Withdrawal = decodeJSON(from: data, as: Withdrawal.self) {
                // Find and update the withdrawal in the array
                if let index = self.withdrawals.firstIndex(where: { $0.id_recover == withdrawalID }) {
                    self.withdrawals[index] = withdrawal
                } else {
                    // Add it if not found
                    self.withdrawals.append(withdrawal)
                }
                
                self.errorMessage = nil
            } else {
                throw NetworkError.invalidMethod
            }
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

extension WithdrawalViewModel {
    func dismissError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
}
