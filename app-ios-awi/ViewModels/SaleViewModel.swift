//
//  SaleViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

@MainActor
class SaleViewModel: ObservableObject {
    @Published var sales: [Sale] = []
    private let endpoint = "sales/"
    
    func fetchSales() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedSales: [Sale] = decodeJSON(from: data, as: [Sale].self) {
                self.sales = fetchedSales
            }
        } catch {
            print("Erreur récupération sales:", error)
        }
    }
    
    func createSale(sale: Sale) async {
        do {
            let body = try JSONEncoder().encode(sale)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            if let newSale: Sale = decodeJSON(from: data, as: Sale.self) {
                self.sales.append(newSale)
            }
        } catch {
            print("Erreur création sale:", error)
        }
    }
    
    func updateSale(sale: Sale) async {
        do {
            let body = try JSONEncoder().encode(sale)
            let data = try await fetchData(from: "\(endpoint)\(sale.id_sale)", reqMethod: "PUT", body: body)
            if let updatedSale: Sale = decodeJSON(from: data, as: Sale.self),
               let index = self.sales.firstIndex(where: { $0.id_sale == updatedSale.id_sale }) {
                self.sales[index] = updatedSale
            }
        } catch {
            print("Erreur modification sale:", error)
        }
    }
    
    func deleteSale(saleID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(saleID)", reqMethod: "DELETE")
            self.sales.removeAll { $0.id_sale == saleID }
        } catch {
            print("Erreur suppression sale:", error)
        }
    }
}
