//
// SellerViewModel.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import Foundation

@MainActor
class SellerViewModel: ObservableObject {
    @Published var sellers: [Seller] = []
    private let endpoint = "sellers"

    // Fetch all sellers
    func fetchSellers() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedSellers: [Seller] = decodeJSON(from: data, as: [Seller].self) {
                self.sellers = fetchedSellers
            }
        } catch {
            print("Erreur récupération sellers:", error)
        }
    }

    // Create a new seller
    func createSeller(seller: Seller) async {
        do {
            let body = try JSONEncoder().encode(seller)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            
            if let newSeller: Seller = decodeJSON(from: data, as: Seller.self) {
                self.sellers.append(newSeller) // Add new seller to list
            }
        } catch {
            print("Erreur création seller:", error)
        }
    }

    // Update an existing seller
    func updateSeller(seller: Seller) async {
        do {
            let body = try JSONEncoder().encode(seller)
            let data = try await fetchData(from: "\(endpoint)/\(seller.id_seller)", reqMethod: "PUT", body: body)
            
            if let updatedSeller: Seller = decodeJSON(from: data, as: Seller.self) {
                if let index = self.sellers.firstIndex(where: { $0.id_seller == updatedSeller.id_seller }) {
                    self.sellers[index] = updatedSeller // Update local list
                }
            }
        } catch {
            print("Erreur modification seller:", error)
        }
    }

    // Delete a seller
    func deleteSeller(sellerID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)/\(sellerID)", reqMethod: "DELETE")
            self.sellers.removeAll { $0.id_seller == sellerID } // Remove from local list
        } catch {
            print("Erreur suppression seller:", error)
        }
    }
}
