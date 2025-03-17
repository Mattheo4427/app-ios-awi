//
//  LoginViewModel.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isPasswordSecure = true
    @Published var showErrorMessage = false
    @Published var isLoading = false
    
    func validateCredentials() -> Bool {
        // A simple check to make sure email and password are non-empty
        if email.isEmpty || password.isEmpty || !email.contains("@") {
            return false
        }
        return true
    }

    func login() {
        // Trigger loading state
        isLoading = true
        showErrorMessage = false

        // Here you can add your API request or login logic
        // For simplicity, we just simulate a delay to represent login logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            if self.validateCredentials() {
                // Handle successful login logic
                print("Login successful")
            } else {
                // Handle failed login logic
                self.showErrorMessage = true
            }
        }
    }
}
