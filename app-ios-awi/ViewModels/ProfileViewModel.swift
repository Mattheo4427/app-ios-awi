//
//  ProfileViewModel.swift
//  app-ios-awi
//
//  Created by etud on 19/03/2025.
//

import SwiftUI

struct ManagerProfile: Codable {
    let id_manager: String
    let username: String
    let email: String
    let is_admin: Bool
}

class ProfileViewModel: ObservableObject {
    @AppStorage("authToken") var authToken = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userRole") var userRole = "client"

    @Published var showLogoutConfirmation = false
    @Published var navigateToLogin = false
    @Published var managerProfile: ManagerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isAuthenticated: Bool {
        !authToken.isEmpty
    }

    var username: String {
        managerProfile?.username ?? "Utilisateur inconnu"
    }

    var email: String {
        managerProfile?.email ?? "Email inconnu"
    }

    var isAdmin: Bool {
        managerProfile?.is_admin ?? false
    }

    init() {
        checkAuthState()
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

    /// Récupère le profil de l'utilisateur
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

        do {
            let data = try await fetchData(from: "managers/get/current", token: authToken)
            if let profile = decodeJSON(from: data, as: ManagerProfile.self) {
                DispatchQueue.main.async {
                    self.managerProfile = profile
                    self.userRole = profile.is_admin ? "admin" : "client"
                }
                print("🟢 Profil chargé avec succès: \(profile.username)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Impossible de charger le profil."
            }
            print("🔴 Échec du chargement du profil: \(error)")
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    /// Déconnecte l'utilisateur et réinitialise les valeurs
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userRole")
        UserDefaults.standard.synchronize()

        DispatchQueue.main.async {
            self.authToken = ""
            self.isLoggedIn = false
            self.userRole = "client"
            self.managerProfile = nil
            self.navigateToLogin = true
        }

        print("🚪 Déconnexion réussie. isLoggedIn = \(isLoggedIn), userRole = \(userRole), authToken supprimé.")
    }

    /// Affiche les valeurs stockées pour debug
    func printAppStorageValues() {
        print("🔍 isLoggedIn: \(isLoggedIn), userRole: \(userRole), authToken: \(authToken)")
    }
}
