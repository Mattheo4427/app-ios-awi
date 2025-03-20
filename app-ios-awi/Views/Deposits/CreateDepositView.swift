//
//  CreateDepositView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateDepositView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DepositViewModel
    
    @State private var idSeller = ""
    @State private var idGame = ""
    @State private var quantity = ""
    @State private var unitaryPrice = ""
    
    var body: some View {
        Form {
            Section {
                TextField("ID Seller", text: $idSeller)
                TextField("ID Game", text: $idGame)
                    .keyboardType(.numberPad)
                TextField("Quantité", text: $quantity)
                    .keyboardType(.numberPad)
                TextField("Prix Unitaire", text: $unitaryPrice)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                Button("Créer Dépôt") {
                    Task {
                        let newDeposit = Deposit(
                            id_seller: idSeller,
                            id_game: Int(idGame) ?? 0,
                            quantity: Int(quantity) ?? 0,
                            unitary_price: Double(unitaryPrice) ?? 0
                        )
                        await viewModel.createDeposit(deposit: newDeposit)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Nouveau Dépôt")
    }
}