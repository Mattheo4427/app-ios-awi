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
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("is_admin") var is_admin = false
    @AppStorage("authToken") var authToken = ""

    @Published var showLogoutConfirmation = false
    @Published var navigateToLogin = false
    @Published var managerProfile: ManagerProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var username: String {
        managerProfile?.username ?? "Utilisateur inconnu"
    }

    var email: String {
        managerProfile?.email ?? "Email inconnu"
    }

    func fetchProfile() async {
        guard !authToken.isEmpty else {
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
                    self.is_admin = profile.is_admin
                }
                print("🟢 Profile fetched successfully: \(profile.username)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Impossible de charger le profil."
            }
            print("🔴 Failed to fetch profile: \(error)")
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    func logout() {
        isLoggedIn = false
        is_admin = false
        authToken = ""

        UserDefaults.standard.synchronize()
        navigateToLogin = true
        print("🚪 User logged out successfully")
    }
}

