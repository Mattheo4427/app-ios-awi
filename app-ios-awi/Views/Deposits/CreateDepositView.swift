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
    
    @State private var date = Date()
    @State private var quantity = ""
    @State private var totalPrice = ""
    @State private var amount = ""
    @State private var fees = ""
    @State private var discount = ""
    @State private var idSeller = ""
    @State private var idSession = ""
    @State private var unitaryPrice = ""
    @State private var idGame = ""
    
    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("ID Game", text: $idGame)
                    .keyboardType(.numberPad)
                TextField("Quantité", text: $quantity)
                    .keyboardType(.numberPad)
                TextField("Prix Total", text: $totalPrice)
                    .keyboardType(.decimalPad)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Fees", text: $fees)
                    .keyboardType(.decimalPad)
                TextField("Discount", text: $discount)
                    .keyboardType(.decimalPad)
                TextField("ID Seller", text: $idSeller)
                TextField("ID Session", text: $idSession)
                    .keyboardType(.numberPad)
                TextField("Prix Unitaire", text: $unitaryPrice)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                Button("Créer Dépôt") {
                    Task {
                        let newDeposit = Deposit(
                            id_deposit: UUID().uuidString, // Temporary ID
                            id_game: Int(idGame) ?? 0,
                            quantity: Int(quantity) ?? 0,
                            date: date,
                            total_price: Double(totalPrice) ?? 0,
                            amount: Double(amount) ?? 0,
                            fees: Double(fees) ?? 0,
                            discount: Double(discount) ?? 0,
                            id_seller: idSeller,
                            id_session: Int(idSession) ?? 0,
                            unitary_price: Double(unitaryPrice) ?? 0,
                            games_deposited: [] // Extend UI to add deposited games if needed
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
