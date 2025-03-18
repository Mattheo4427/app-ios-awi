//
//  DepositViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

@MainActor
class DepositViewModel: ObservableObject {
    @Published var deposits: [Deposit] = []
    private let endpoint = "deposits/"
    
    func fetchDeposits() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedDeposits: [Deposit] = decodeJSON(from: data, as: [Deposit].self) {
                self.deposits = fetchedDeposits
            }
        } catch {
            print("Erreur récupération deposits:", error)
        }
    }
    
    func createDeposit(deposit: Deposit) async {
        do {
            let body = try JSONEncoder().encode(deposit)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            if let newDeposit: Deposit = decodeJSON(from: data, as: Deposit.self) {
                self.deposits.append(newDeposit)
            }
        } catch {
            print("Erreur création deposit:", error)
        }
    }
    
    func updateDeposit(deposit: Deposit) async {
        do {
            let body = try JSONEncoder().encode(deposit)
            let data = try await fetchData(from: "\(endpoint)\(deposit.id_deposit)", reqMethod: "PUT", body: body)
            if let updatedDeposit: Deposit = decodeJSON(from: data, as: Deposit.self),
               let index = self.deposits.firstIndex(where: { $0.id_deposit == updatedDeposit.id_deposit }) {
                self.deposits[index] = updatedDeposit
            }
        } catch {
            print("Erreur modification deposit:", error)
        }
    }
    
    func deleteDeposit(depositID: String) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(depositID)", reqMethod: "DELETE")
            self.deposits.removeAll { $0.id_deposit == depositID }
        } catch {
            print("Erreur suppression deposit:", error)
        }
    }
}
