//
// CreateManagerView.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import SwiftUI

struct CreateManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ManagerViewModel
    
    @State private var username = ""
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var password = ""
    @State private var isAdmin = false // Toggle for admin role
    
    var body: some View {
        Form {
            TextField("Nom d'utilisateur", text: $username)
            TextField("Prénom", text: $firstname)
            TextField("Nom", text: $lastname)
            TextField("Email", text: $email)
            TextField("Téléphone", text: $phone)
            TextField("Addresse", text: $address)
            SecureField("Mot de passe", text: $password)
            Toggle("Admin", isOn: $isAdmin)
            
            Button("Créer Manager") {
                Task {
                    let newManager = Manager(
                        id_manager: UUID().uuidString, // Temporary ID using UUID
                        username: username,
                        email: email,
                        password: "temporaryPassword", // Assuming password handling
                        firstname: firstname,
                        lastname: lastname,
                        phone: phone,
                        address: address.isEmpty ? nil : address,
                        is_admin: isAdmin
                    )
                    await viewModel.createManager(manager: newManager)
                    // Only dismiss if there was no error
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Nouveau Manager")
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
}
