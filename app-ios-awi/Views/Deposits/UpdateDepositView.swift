//
//  UpdateDepositView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateDepositView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DepositViewModel
    @State var deposit: Deposit

    var body: some View {
        Form {
            Section {
                TextField("ID Game", text: Binding(
                    get: { String(deposit.id_game) },
                    set: { deposit.id_game = Int($0) ?? 0 }
                ))
                    .keyboardType(.numberPad)
                
                TextField("Quantité", text: Binding(
                    get: { String(deposit.quantity) },
                    set: { deposit.quantity = Int($0) ?? 0 }
                ))
                    .keyboardType(.numberPad)
                
                DatePicker("Date", selection: Binding(
                    get: { deposit.date ?? Date() },
                    set: { deposit.date = $0 }
                ), displayedComponents: .date)
                
                TextField("Prix Total", text: Binding(
                    get: { String(deposit.total_price) },
                    set: { deposit.total_price = Double($0) ?? 0 }
                ))
                    .keyboardType(.decimalPad)
                
                TextField("Amount", text: Binding(
                    get: { String(deposit.amount) },
                    set: { deposit.amount = Double($0) ?? 0 }
                ))
                    .keyboardType(.decimalPad)
                
                TextField("Fees", text: Binding(
                    get: { String(deposit.fees) },
                    set: { deposit.fees = Double($0) ?? 0 }
                ))
                    .keyboardType(.decimalPad)
                
                TextField("Discount", text: Binding(
                    get: { String(deposit.discount) },
                    set: { deposit.discount = Double($0) ?? 0 }
                ))
                    .keyboardType(.decimalPad)
                
                TextField("ID Seller", text: $deposit.id_seller)
                
                TextField("ID Session", text: Binding(
                    get: { String(deposit.id_session) },
                    set: { deposit.id_session = Int($0) ?? 0 }
                ))
                    .keyboardType(.numberPad)
                
                TextField("Prix Unitaire", text: Binding(
                    get: { String(deposit.unitary_price) },
                    set: { deposit.unitary_price = Double($0) ?? 0 }
                ))
                    .keyboardType(.decimalPad)
            }
            
            Section {
                // Optionally add view for editing games_deposited.
                Button("Modifier Dépôt") {
                    Task {
                        await viewModel.updateDeposit(deposit: deposit)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Modification Dépôt")
    }
}
