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
            TextField("Nom d'utilisateur", text: $seller.username)
            TextField("Prénom", text: $seller.firstname)
            TextField("Nom", text: $seller.lastname)
            TextField("Email", text: $seller.email)
            TextField("Téléphone", text: Binding(
                get: { seller.phone ?? "" },
                set: { seller.phone = $0.isEmpty ? nil : $0 }
            ))
            TextField("Addresse", text: Binding(
                get: { seller.address ?? "" },
                set: { seller.address = $0.isEmpty ? nil : $0 }
            ))

            Button("Modifier Vendeur") {
                Task {
                    await viewModel.updateSeller(seller: seller)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Vendeur")
    }
}
