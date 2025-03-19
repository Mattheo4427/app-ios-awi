//
//  WithdrawalViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation

@MainActor
class WithdrawalViewModel: ObservableObject {
    @Published var withdrawals: [Withdrawal] = []
    private let endpoint = "recovers/"
    
    func fetchWithdrawals() async {
        do {
            let data = try await fetchData(from: endpoint)
            if let fetchedWithdrawals: [Withdrawal] = decodeJSON(from: data, as: [Withdrawal].self) {
                self.withdrawals = fetchedWithdrawals
            }
        } catch {
            print("Erreur récupération retraits:", error)
        }
    }
    
    func createWithdrawal(withdrawal: Withdrawal) async {
        do {
            let body = try JSONEncoder().encode(withdrawal)
            let data = try await fetchData(from: endpoint, reqMethod: "POST", body: body)
            if let newWithdrawal: Withdrawal = decodeJSON(from: data, as: Withdrawal.self) {
                self.withdrawals.append(newWithdrawal)
            }
        } catch {
            print("Erreur création retrait:", error)
        }
    }
    
    func updateWithdrawal(withdrawal: Withdrawal) async {
        do {
            let body = try JSONEncoder().encode(withdrawal)
            let data = try await fetchData(from: "\(endpoint)\(withdrawal.id_withdrawal)", reqMethod: "PUT", body: body)
            if let updatedWithdrawal: Withdrawal = decodeJSON(from: data, as: Withdrawal.self),
               let index = self.withdrawals.firstIndex(where: { $0.id_withdrawal == updatedWithdrawal.id_withdrawal }) {
                self.withdrawals[index] = updatedWithdrawal
            }
        } catch {
            print("Erreur modification retrait:", error)
        }
    }
    
    func deleteWithdrawal(withdrawalID: Int) async {
        do {
            _ = try await fetchData(from: "\(endpoint)\(withdrawalID)", reqMethod: "DELETE")
            self.withdrawals.removeAll { $0.id_withdrawal == withdrawalID }
        } catch {
            print("Erreur suppression retrait:", error)
        }
    }
}
