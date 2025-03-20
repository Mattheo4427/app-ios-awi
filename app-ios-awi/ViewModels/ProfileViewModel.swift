//
//  ProfileViewModel.swift
//  app-ios-awi
//
//  Created by etud on 19/03/2025.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userRole") var userRole = "client"
    @AppStorage("authToken") var authToken = ""
    
    @Published var showLogoutConfirmation = false
    @Published var navigateToLogin = false
    
    func logout() {
        // Clear auth credentials and user data
        isLoggedIn = false
        userRole = "client"
        authToken = ""
        
        // Force refresh AppStorage values
        UserDefaults.standard.synchronize()
        
        // Set flag to navigate back to login screen
        navigateToLogin = true
        
        print("🚪 User logged out successfully")
    }
}