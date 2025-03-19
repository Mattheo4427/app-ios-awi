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
    @AppStorage("userRole") var userRole = "client"  // Default to "client" (not connected)
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
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let response = decodeJSON(from: data, as: LoginResponse.self) {
                    self.isLoggedIn = true
                    self.authToken = response.accesstoken  // Store the JWT token
                    
                    // Extract role from JWT token
                    self.userRole = self.extractRole(from: response.accesstoken)
                    
                    print("Login successful: \(response.accesstoken), Role: \(self.userRole)")
                } else if let errorResponse = decodeJSON(from: data, as: ErrorResponse.self) {
                    self.showErrorMessage = true
                    self.errorMessage = errorResponse.message
                } else {
                    self.showErrorMessage = true
                    self.errorMessage = "Erreur inconnue."
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
    }

    private func extractRole(from token: String) -> String {
        do {
            let jwt = try decode(jwt: token)
            if let role = jwt.claim(name: "role").string {
                return role
            }
        } catch {
            print("JWT decoding error: \(error.localizedDescription)")
        }
        return "client"
    }
}

// Structs to handle responses
struct LoginResponse: Decodable {
    let accesstoken: String
}

struct ErrorResponse: Decodable {
    let message: String
}
