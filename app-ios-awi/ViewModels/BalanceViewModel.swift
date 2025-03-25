//
//  BalanceViewModel.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import Foundation
import SwiftUI

//Structure de données pour les infos d'une session
struct SessionBalance: Decodable {
    let id_session: Int
    let name: String
    let date_begin: Date
    let date_end: Date
    let deposit_fees: String
    let discount: String
    let comission_fees: String
}

//Structure de données pour les infos d'une vente
struct SaleBalance: Decodable {
    let id_sale: String
    let date: Date
    let amount: String
    let comission: String
    let payment_method: String
    let id_seller: String
    let id_client: Int
    let id_manager: String
}

//Structure de données pour les infos d'une récupération
struct RecoverBalance: Decodable {
    let id_recover: String
    let date: Date
    let amount: String
    let id_seller: String
    let id_manager: String
}

//Structure de données pour les infos d'un dépôt
struct DepositBalance: Decodable {
    let id_deposit: String
    let date: Date
    let amount: String
    let fees: String
    let discount: String
    let id_seller: String
    let id_manager: String
}


@MainActor
class BalanceViewModel: ObservableObject {
    @AppStorage("authToken") var authToken = ""
    @AppStorage("userRole") var userRole = "client"  // Store "manager" or "seller"

    @Published var sessionBalance: SessionBalance?
    @Published var sales: [SaleBalance] = []
    @Published var recovers: [RecoverBalance] = []
    @Published var deposits: [DepositBalance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sellerId: String?
    
    // Variables observables pour stocker les statistiques calculées du manager
    @Published var totalSalesAmount: Double = 0
    @Published var totalSalesCount: Int = 0
    @Published var totalCommissions: Double = 0
    @Published var averageTicket: Double = 0
    @Published var paymentDistribution: [String: Int] = [:]

    @Published var totalDepositsAmount: Double = 0
    @Published var totalDepositsCount: Int = 0
    @Published var totalDepositFees: Double = 0
    @Published var totalDepositDiscounts: Double = 0
    @Published var averageDepositAmount: Double = 0

    @Published var totalRecoversAmount: Double = 0
    @Published var totalRecoversCount: Int = 0
    
    // Variables observables pour stocker les statistiques calculées du seller
    @Published var sellerTotalSalesAmount: Double = 0
    @Published var sellerTotalSalesCount: Int = 0
    @Published var sellerTotalCommissions: Double = 0
    @Published var sellerAverageTicket: Double = 0
    @Published var sellerPaymentDistribution: [String: Int] = [:]
    

    var isAuthenticated: Bool {
        !authToken.isEmpty
    }

    //Type d'utilisateur possible
    var userType: UserType {
        switch userRole {
            case "admin": return .manager
            case "manager": return .manager
            case "seller": return .seller
            default: return .unknown
        }
    }

    //Vérifie l'état d'authentification
    func checkAuthState() {
        if authToken.isEmpty {
            print("🔍 No token found, resetting authentication state.")
            userRole = "client"
        } else {
            print("✅ Token found, user authenticated.")
        }
    }
    
    
    // Méthode pour recalculer les statistiques
    func computeBalanceStatistics() {
        guard let sessionBalance = sessionBalance else { return }

        // 🟠 Calculs pour les ventes
        totalSalesCount = sales.count
        totalSalesAmount = sales.reduce(0) { $0 + (Double($1.amount) ?? 0) }
        totalCommissions = sales.reduce(0) { $0 + (Double($1.comission) ?? 0) }
        averageTicket = totalSalesCount > 0 ? totalSalesAmount / Double(totalSalesCount) : 0

        // Répartition des paiements
        paymentDistribution = Dictionary(grouping: sales, by: { $0.payment_method })
            .mapValues { $0.count }

        // 🔵 Calculs pour les dépôts
        totalDepositsCount = deposits.count
        totalDepositsAmount = deposits.reduce(0) { $0 + (Double($1.amount) ?? 0) }
        totalDepositFees = Double(sessionBalance.deposit_fees) ?? 0 * Double(totalDepositsCount)
        totalDepositDiscounts = Double(sessionBalance.discount) ?? 0 * Double(totalDepositsCount)
        averageDepositAmount = totalDepositsCount > 0 ? totalDepositsAmount / Double(totalDepositsCount) : 0

        // 🟣 Calculs pour les récupérations
        totalRecoversCount = recovers.count
        totalRecoversAmount = recovers.reduce(0) { $0 + (Double($1.amount) ?? 0) }
    }
    
    // Méthode pour recalculer les statistiques pour le Seller
    func computeSellerStatistics() {
        // 🟠 Calculs pour les ventes du Seller
        sellerTotalSalesCount = sales.count
        sellerTotalSalesAmount = sales.reduce(0) { $0 + (Double($1.amount) ?? 0) }
        sellerTotalCommissions = sales.reduce(0) { $0 + (Double($1.comission) ?? 0) }
        sellerAverageTicket = sellerTotalSalesCount > 0 ? sellerTotalSalesAmount / Double(sellerTotalSalesCount) : 0

        // Répartition des paiements
        sellerPaymentDistribution = Dictionary(grouping: sales, by: { $0.payment_method })
            .mapValues { $0.count }
    }
    
    var formattedSellerPaymentDistribution: String {
            let translations: [String: String] = [
                "cash": "Espèces",
                "credit_card": "Carte de crédit",
                "check": "Autres"
            ]
            
            let formatted = sellerPaymentDistribution.map { key, value in
                let translatedKey = translations[key] ?? key
                return "\(translatedKey): \(value)"
            }
            
            return formatted.joined(separator: ", ")
        }
    
    var formattedPaymentDistribution: String {
            let translations: [String: String] = [
                "cash": "Espèces",
                "credit_card": "Carte de crédit",
                "check": "Autres"
            ]
            
            let formatted = paymentDistribution.map { key, value in
                let translatedKey = translations[key] ?? key
                return "\(translatedKey): \(value)"
            }
            
            return formatted.joined(separator: ", ")
        }
    
    
//--Méthodes de fetch--
    

    //Récupère les informations de l'utilisateur
    func fetchProfile() async -> String? {
            guard isAuthenticated else {
                DispatchQueue.main.async {
                    self.errorMessage = "No authentication token available."
                }
                return nil
            }

            let endpoint: String
            switch userType {
            case .manager:
                return nil  // No need to fetch profile for manager
            case .seller:
                endpoint = "sellers/get/current"
            case .unknown:
                DispatchQueue.main.async {
                    self.errorMessage = "Unknown user type."
                }
                return nil
            }

            do {
                let data = try await fetchData(from: endpoint, token: authToken)
                if let profile = decodeJSON(from: data, as: SellerProfile.self) {
                    DispatchQueue.main.async {
                        self.sellerId = profile.id_seller
                        print("🟢 Seller ID fetched: \(profile.id_seller)")
                    }
                    return profile.id_seller
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Unable to load profile."
                    }
                    return nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error loading profile."
                }
                print("🔴 Failed to fetch profile: \(error)")
                return nil
            }
        }

    // ✅ Mise à jour automatique après le chargement des données
    func fetchBalance() async {
            guard isAuthenticated else {
                DispatchQueue.main.async {
                    self.errorMessage = "No authentication token available."
                }
                return
            }

            DispatchQueue.main.async {
                self.isLoading = true
                self.errorMessage = nil
            }

            do {
                switch userType {
                case .manager:
                    try await fetchBalanceForManager()
                case .seller:
                    if let sellerId = await fetchProfile() {
                        print("Seller ID: \(sellerId)")
                        try await fetchBalanceForSeller(sellerId: sellerId)
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Seller ID not available."
                        }
                    }
                case .unknown:
                    DispatchQueue.main.async {
                        self.errorMessage = "Unknown user type."
                        self.isLoading = false
                    }
                }

                // Appel des calculs une fois les données récupérées
                DispatchQueue.main.async {
                    self.computeBalanceStatistics()
                    if self.userType == .seller {
                        self.computeSellerStatistics()
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching balance."
                }
                print("🔴 Failed to fetch balance: \(error)")
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }


    private func fetchBalanceForManager() async throws {
        if let sessionData = try await fetchData(from: "sessions/opened", token: authToken),
           let session = decodeJSON(from: sessionData, as: SessionBalance.self) {
            self.sessionBalance = session
        }

        guard let id_session = sessionBalance?.id_session else { return }

        if let salesData = try await fetchData(from: "sales/session/\(id_session)", token: authToken) {
            self.sales = decodeJSON(from: salesData, as: [SaleBalance].self) ?? []
        }

        if let depositsData = try await fetchData(from: "deposits/session/\(id_session)", token: authToken) {
            self.deposits = decodeJSON(from: depositsData, as: [DepositBalance].self) ?? []
        }

        if let recoversData = try await fetchData(from: "recovers/session/\(id_session)", token: authToken) {
            self.recovers = decodeJSON(from: recoversData, as: [RecoverBalance].self) ?? []
        }
    }

    private func fetchBalanceForSeller(sellerId: String) async throws {
        print("Fetching balance for seller ID: \(sellerId)")
        
        if let salesData = try await fetchData(from: "sales/seller/\(sellerId)", token: authToken) {
            self.sales = decodeJSON(from: salesData, as: [SaleBalance].self) ?? []
        }

        if let depositsData = try await fetchData(from: "deposits/seller/\(sellerId)", token: authToken) {
            self.deposits = decodeJSON(from: depositsData, as: [DepositBalance].self) ?? []
        }

        if let recoversData = try await fetchData(from: "recovers/seller/\(sellerId)", token: authToken) {
            self.recovers = decodeJSON(from: recoversData, as: [RecoverBalance].self) ?? []
        }
    }
}


//--Structures de vues--


//Structure pour une ligne de ventes
struct SaleRow: View {
    let sale: SaleBalance

    var body: some View {
        VStack(alignment: .leading) {
            Text("Sale ID: \(sale.id_sale)")
                .font(.headline)
            Text("Amount: \(sale.amount)")
                .font(.subheadline)
            Text("Commission: \(sale.comission)")
                .font(.subheadline)
            Text("Payment Method: \(sale.payment_method)")
                .font(.subheadline)
            Text("Date: \(sale.date, formatter: dateFormatter)")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}


//Structure pour une ligne de dépôts
struct DepositRow: View {
    let deposit: DepositBalance

    var body: some View {
        VStack(alignment: .leading) {
            Text("Deposit ID: \(deposit.id_deposit)")
                .font(.headline)
            Text("Amount: \(deposit.amount)")
                .font(.subheadline)
            Text("Fees: \(deposit.fees)")
                .font(.subheadline)
            Text("Discount: \(deposit.discount)")
                .font(.subheadline)
            Text("Date: \(deposit.date, formatter: dateFormatter)")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

//Structure pour une ligne de récupérations
struct RecoverRow: View {
    let recover: RecoverBalance

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recover ID: \(recover.id_recover)")
                .font(.headline)
            Text("Amount: \(recover.amount)")
                .font(.subheadline)
            Text("Date: \(recover.date, formatter: dateFormatter)")
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

