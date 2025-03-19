//
//  ProfileView.swift
//  app-ios-awi
//
//  Created by etud on 19/03/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Mon Profil")
                        .font(.title)
                        .fontWeight(.medium)
                    
                    Text("Informations de profil et paramètres du compte")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Logout Button
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Déconnexion")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                // Logout Confirmation Dialog
                .alert("Déconnexion", isPresented: $showLogoutConfirmation) {
                    Button("Annuler", role: .cancel) { }
                    Button("Déconnexion", role: .destructive) {
                        viewModel.logout()
                    }
                } message: {
                    Text("Êtes-vous sûr de vouloir vous déconnecter?")
                }
                
                // Navigation link to login page when logged out
                NavigationLink(destination: LoginView(), isActive: $viewModel.navigateToLogin) {
                    EmptyView()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}