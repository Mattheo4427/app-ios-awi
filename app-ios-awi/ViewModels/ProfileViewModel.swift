//
//  ProfileViewModel.swift
//  app-ios-awi
//
//  Created by etud on 19/03/2025.
//

import SwiftUI
import Foundation

struct ManagerProfile: Codable {
    let id_manager: String
    let username: String
    let firstname: String
    let lastname: String
    let email: String
    let phone: String
    let address: String?
    let is_admin: Bool
    let createdAt: String
}

struct SellerProfile: Codable {
    let id_seller: String
    let username: String?
    let firstname: String
    let lastname: String
    let email: String
    let phone: String?
    let address: String?
    let createdAt: String
}

enum UserType {
    case manager, seller, unknown
}

class ProfileViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("authToken") var authToken = ""
    @AppStorage("userRole") var userRole = "client"  // Stocke "manager" ou "seller"

    @Published var showLogoutConfirmation = false
    @Published var navigateToLogin = false
    @Published var managerProfile: ManagerProfile?
    @Published var sellerProfile: SellerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isAuthenticated: Bool {
        !authToken.isEmpty
    }

    var userType: UserType {
        switch userRole {
            case "admin": return .manager
            case "manager": return .manager
            case "seller": return .seller
            default: return .unknown
        }
    }
    
    /// Vérifie l'état d'authentification au démarrage
    func checkAuthState() {
        if authToken.isEmpty {
            print("🔍 Aucun token trouvé, réinitialisation de l'état d'authentification.")
            isLoggedIn = false
            userRole = "client"
        } else {
            print("✅ Token trouvé, utilisateur authentifié.")
            isLoggedIn = true
        }
    }

    func fetchProfile() async {
        guard isAuthenticated else {
            DispatchQueue.main.async {
                self.errorMessage = "Aucun token d'authentification disponible."
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        let endpoint: String
        switch userType {
        case .manager:
            endpoint = "managers/get/current"
        case .seller:
            endpoint = "sellers/get/current"
        case .unknown:
            DispatchQueue.main.async {
                self.errorMessage = "Type d'utilisateur inconnu."
                self.isLoading = false
            }
            return
        }

        do {
            let data = try await fetchData(from: endpoint, token: authToken)

            DispatchQueue.main.async {
                if self.userType == .manager, let profile = decodeJSON(from: data, as: ManagerProfile.self) {
                    self.managerProfile = profile
                    print("🟢 Manager profile fetched: \(profile.username)")
                } else if self.userType == .seller, let profile = decodeJSON(from: data, as: SellerProfile.self) {
                    self.sellerProfile = profile
                    print("🟢 Seller profile fetched: \(profile.firstname) \(profile.lastname)")
                } else {
                    self.errorMessage = "Impossible de charger le profil."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur lors du chargement du profil."
            }
            print("🔴 Failed to fetch profile: \(error)")
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.synchronize()

        isLoggedIn = false
        authToken = ""
        userRole = "client"
        navigateToLogin = true
        print("🚪 Déconnexion réussie")
    }

    func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        } else {
            return dateString
        }
    }

    func printAppStorageValues() {
        print("🔍 isLoggedIn: \(isAuthenticated), authToken: \(authToken), userRole: \(userRole)")
    }
}
