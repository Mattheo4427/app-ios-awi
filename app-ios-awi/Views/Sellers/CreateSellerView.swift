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

    var body: some View {
        Form {
            TextField("Nom d'utilisateur", text: $username)
            TextField("Prénom", text: $firstname)
            TextField("Nom", text: $lastname)
            TextField("Email", text: $email)
            TextField("Téléphone", text: $phone)
            TextField("Addresse", text: $address)
            SecureField("Mot de passe", text: $password)
            
            Button("Créer Vendeur") {
                Task {
                    let newSeller = Seller(
                        id_seller: UUID().uuidString, // Temporary ID using UUID
                        username: username,
                        email: email,
                        password: "temporaryPassword", // Assuming you can manage password securely
                        firstname: firstname,
                        lastname: lastname,
                        phone: phone,
                        address: address.isEmpty ? nil : address
                    )
                    await viewModel.createSeller(seller: newSeller)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouveau Vendeur")
    }
}
