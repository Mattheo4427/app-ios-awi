//
// CreateSellerView.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import SwiftUI

struct CreateSellerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SellerViewModel
    
    @State private var username = ""
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    private var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    private var passwordError: String? {
        if confirmPassword.isEmpty {
            return nil
        }
        return passwordsMatch ? nil : "Les mots de passe ne correspondent pas"
    }

    var body: some View {
        Form {
            Section(header: Text("Compte")) {
                VStack(alignment: .leading) {
                    Text("Nom d'utilisateur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom d'utilisateur", text: $username)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Mot de passe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        if showPassword {
                            TextField("Mot de passe", text: $password)
                        } else {
                            SecureField("Mot de passe", text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Confirmer le mot de passe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        if showPassword {
                            TextField("Confirmer le mot de passe", text: $confirmPassword)
                        } else {
                            SecureField("Confirmer le mot de passe", text: $confirmPassword)
                        }

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if let error = passwordError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Rest of your existing form sections...
            Section(header: Text("Informations personnelles")) {
                VStack(alignment: .leading) {
                    Text("Prénom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prénom", text: $firstname)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Nom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $lastname)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Coordonnées")) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Téléphone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Téléphone", text: $phone)
                        .keyboardType(.phonePad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Adresse", text: $address)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Créer Vendeur") {
                    Task {
                        let newSeller = Seller(
                            id_seller: UUID().uuidString,
                            username: username,
                            email: email,
                            password: password, 
                            firstname: firstname,
                            lastname: lastname,
                            phone: phone,
                            address: address.isEmpty ? nil : address
                        )
                        await viewModel.createSeller(seller: newSeller)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(!passwordsMatch || password.isEmpty)
            }
        }
        .navigationTitle("Nouveau Vendeur")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}