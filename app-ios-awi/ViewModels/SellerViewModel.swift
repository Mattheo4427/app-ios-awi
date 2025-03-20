//
// SellerViewModel.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import Foundation
import SwiftUI

@MainActor
class SellerViewModel: ObservableObject {
    @Published var sellers: [Seller] = []
    private let endpoint = "sellers/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil

    // Fetch all sellers
    func fetchSellers() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedSellers: [Seller] = decodeJSON(from: data, as: [Seller].self) {
                self.sellers = fetchedSellers
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Create a new seller
    func createSeller(seller: Seller) async {
        do {
            let body = try JSONEncoder().encode(seller)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newSeller: Seller = decodeJSON(from: data, as: Seller.self) {
                self.sellers.append(newSeller)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Update an existing seller
    func updateSeller(seller: Seller) async {
        do {
            let body = try JSONEncoder().encode(seller)
            let data = try await fetchData(from: "\(endpoint)update/\(seller.id_seller)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedSeller: Seller = decodeJSON(from: data, as: Seller.self) {
                if let index = self.sellers.firstIndex(where: { $0.id_seller == updatedSeller.id_seller }) {
                    self.sellers[index] = updatedSeller
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }

    // Delete a seller
    func deleteSeller(sellerID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)delete/\(sellerID)", reqMethod: "DELETE", token: authToken)
            self.sellers.removeAll { $0.id_seller == sellerID }
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