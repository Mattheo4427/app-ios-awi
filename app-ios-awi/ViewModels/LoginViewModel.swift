//
//  LoginViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI
import JWTDecode

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordSecure = true
    @Published var showErrorMessage = false
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    @Published var loginSuccess = false

    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userRole") var userRole = "client"
    @AppStorage("authToken") var authToken = ""

    private let urlPath = "auth/login/"

    func validateCredentials() -> Bool {
        return !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    func login() async {
        guard validateCredentials() else {
            DispatchQueue.main.async {
                self.showErrorMessage = true
                self.errorMessage = "Entrez un email et mot de passe valides."
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.showErrorMessage = false
        }

        let parameters = ["email": email, "password": password]
        guard let jsonData = try? JSONEncoder().encode(parameters) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.showErrorMessage = true
                self.errorMessage = "Erreur lors de l'encodage des données."
            }
            return
        }

        do {
            let data = try await fetchData(from: urlPath, reqMethod: "POST", body: jsonData)
            
            // First, decode response and extract role outside of main thread
            if let response = decodeJSON(from: data, as: LoginResponse.self) {
                // Extract the role from the response structure
                let extractedRole = extractRole(from: response)
                print("🔍 Before updating, current role: \(self.userRole)")
                
                // Then update all UI state on main thread at once
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isLoggedIn = true
                    self.authToken = response.accesstoken
                    self.userRole = extractedRole
                    print("🎯 Login successful: Token length: \(response.accesstoken.count) characters")
                    print("🔑 Role changed to: \(self.userRole)")
                    
                    // Force refresh AppStorage values
                    UserDefaults.standard.synchronize()
                    
                    // Verify the AppStorage value was updated correctly
                    let storedRole = UserDefaults.standard.string(forKey: "userRole") ?? "none"
                    print("📦 Verified role in UserDefaults: \(storedRole)")
                    
                    // Set loginSuccess to true to trigger navigation
                    self.loginSuccess = true
                }
                    
                } else if let errorResponse = decodeJSON(from: data, as: ErrorResponse.self) {
                    self.showErrorMessage = true
                    self.errorMessage = errorResponse.message
                } else {
                    self.showErrorMessage = true
                    self.errorMessage = "Erreur inconnue."
                }
            
        } catch let networkError as NetworkError {
            DispatchQueue.main.async {
                self.isLoading = false
                self.showErrorMessage = true
                
                // Get specific network error message
                switch networkError {
                case .invalidURL:
                    self.errorMessage = "URL invalide."
                case .invalidMethod:
                    self.errorMessage = "Méthode de requête invalide."
                case .requestFailed(let statusCode):
                    self.errorMessage = "Échec de la requête avec le code: \(statusCode)."
                case .noData:
                    self.errorMessage = "Aucune donnée reçue."
                case .decodingError(let message):
                    self.errorMessage = "Erreur de décodage: \(message)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.showErrorMessage = true
                self.errorMessage = "Erreur réseau: \(error.localizedDescription)"
            }
        }
    }

    func logout() {
        isLoggedIn = false
        userRole = "client"
        authToken = ""
        email = ""
        password = ""
        loginSuccess = false
    }

    private func extractRole(from response: LoginResponse) -> String {
        // Check for manager role first (with admin check)
        if let manager = response.manager {
            if manager.is_admin {
                print("🔑 Role detected: admin (manager with admin privileges)")
                return "admin"
            } else {
                print("🔑 Role detected: manager")
                return "manager"
            }
        }
        
        // Check for seller role
        if response.seller != nil {
            print("🔑 Role detected: seller")
            return "seller"
        }
        
        // Try JWT token as fallback (if role structure changes in future)
        do {
            let jwt = try decode(jwt: response.accesstoken)
            if let role = jwt.claim(name: "role").string {
                print("🔑 Role from JWT token: \(role)")
                return role
            }
        } catch {
            print("⚠️ JWT decoding error: \(error.localizedDescription)")
        }
        
        // Default to client role if nothing else found
        print("⚠️ No role information found, defaulting to client")
        return "client"
    }
}

// Structs to handle responses
struct LoginResponse: Decodable {
    let accesstoken: String
    let manager: ManagerData?
    let seller: SellerData?
    
    struct ManagerData: Decodable {
        let id_manager: String
        let is_admin: Bool
    }
    
    struct SellerData: Decodable {
        let id_seller: String
    }
}

struct ErrorResponse: Decodable {
    let message: String
}
