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

    func fetchSaleDetails(id: String) async {
        do {
            // Fix #1: Unwrap optional Data value
            guard let data = try await fetchData(from: "\(endpoint)\(id)", token: authToken) else {
                throw NetworkError.noData
            }
            
            let decoder = JSONDecoder()
            
            // Configure date decoding to handle various date formats
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try multiple date formats
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
                    "yyyy-MM-dd'T'HH:mm:ssZ",
                    "yyyy-MM-dd'T'HH:mm:ss",
                    "yyyy-MM-dd"
                ]
                
                for format in formats {
                    dateFormatter.dateFormat = format
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date: \(dateString)"
                )
            }
            
            if let detailedSale = try? decoder.decode(DetailedSale.self, from: data) {
                // Update the sale in the array with the detailed information
                if let index = self.sales.firstIndex(where: { $0.id_sale == id }) {
                    // Create a new Sale object with the details from DetailedSale
                    var updatedSale = self.sales[index]
                    updatedSale.games_sold = detailedSale.games_sold.map { detailedGame in
                        GameSold(
                            id_game: detailedGame.id_game,
                            quantity: detailedGame.quantity,
                            tags: detailedGame.tags
                        )
                    }
                    
                    self.sales[index] = updatedSale
                }
                
                self.errorMessage = nil
            } else {
                throw NetworkError.decodingError("Failed to decode sale details")
            }
        } catch let networkError as NetworkError {
            handleError(networkError)
        } catch {
            self.errorMessage = "Erreur: \(error.localizedDescription)"
            print("Error fetching sale details: \(error)")
        }
    }
        
    func createSale(sale: Sale) async {
        do {
            let body = try JSONEncoder().encode(sale)
            guard let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body, token: authToken) else {
                self.errorMessage = "Aucune donnée reçue"
                return
            }
            
            // Try to decode as a success message first
            if let successResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let _ = successResponse["data"] {
                // Success message received - fetch the updated list of sales
                await fetchSales()
                self.errorMessage = nil
            } else if let newSale = decodeJSON(from: data, as: Sale.self) {
                // Successfully decoded the new sale object
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
            // Safely unwrap the id_sale to avoid the optional warning
            guard let saleId = sale.id_sale else {
                self.errorMessage = "Erreur: ID de vente manquant"
                return
            }
            
            let data = try await fetchData(from: "\(endpoint)\(saleId)", reqMethod: "PUT", body: body, token: authToken)
            
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
            // The saleID parameter is non-optional, so no warning needed
            _ = try await fetchData(from: "\(endpoint)\(saleID)", reqMethod: "DELETE", token: authToken)
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

extension SaleViewModel {
    func dismissError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
}

