//
//  SaleViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class SaleViewModel: ObservableObject {
    @Published var sales: [Sale] = []
    private let endpoint = "sales/"
    
    @AppStorage("authToken") private var authToken = ""
    @Published var errorMessage: String? = nil
    
    func fetchSales() async {
        do {
            let data = try await fetchData(from: endpoint, token: authToken)
            
            if let fetchedSales: [Sale] = decodeJSON(from: data, as: [Sale].self) {
                self.sales = fetchedSales
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func createSale(sale: Sale) async {
        do {
            let body = try JSONEncoder().encode(sale)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken)
            
            if let newSale: Sale = decodeJSON(from: data, as: Sale.self) {
                self.sales.append(newSale)
                self.errorMessage = nil
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func updateSale(sale: Sale) async {
        do {
            let body = try JSONEncoder().encode(sale)
            let data = try await fetchData(from: "\(endpoint)/\(sale.id_sale)", reqMethod: "PUT", body: body, token: authToken)
            
            if let updatedSale: Sale = decodeJSON(from: data, as: Sale.self) {
                if let index = self.sales.firstIndex(where: { $0.id_sale == updatedSale.id_sale }) {
                    self.sales[index] = updatedSale
                    self.errorMessage = nil
                }
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
        }
    }
    
    func deleteSale(saleID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)/\(saleID)", reqMethod: "DELETE", token: authToken)
            self.sales.removeAll { $0.id_sale == saleID }
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