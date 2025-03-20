//
// UpdateSellerView.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import SwiftUI

struct UpdateSellerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SellerViewModel
    @State var seller: Seller

    var body: some View {
        Form {
            Section(header: Text("Compte")) {
                VStack(alignment: .leading) {
                    Text("Nom d'utilisateur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom d'utilisateur", text: $seller.username)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Informations personnelles")) {
                VStack(alignment: .leading) {
                    Text("Prénom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prénom", text: $seller.firstname)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Nom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $seller.lastname)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Coordonnées")) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $seller.email)
                        .keyboardType(.emailAddress)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Téléphone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Téléphone", text: Binding(
                        get: { seller.phone ?? "" },
                        set: { seller.phone = $0.isEmpty ? nil : $0 }
                    ))
                    .keyboardType(.phonePad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Adresse", text: Binding(
                        get: { seller.address ?? "" },
                        set: { seller.address = $0.isEmpty ? nil : $0 }
                    ))
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Modifier Vendeur") {
                    Task {
                        await viewModel.updateSeller(seller: seller)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Modification Vendeur")
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