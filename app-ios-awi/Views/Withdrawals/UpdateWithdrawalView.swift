//
//  UpdateWithdrawalView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateWithdrawalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WithdrawalViewModel
    @State var withdrawal: Withdrawal

    var body: some View {
        Form {
            DatePicker("Date", selection: Binding(
                get: { withdrawal.date ?? Date() },
                set: { withdrawal.date = $0 }
            ), displayedComponents: .date)
            
            TextField("Montant", text: Binding(
                get: { String(withdrawal.amount) },
                set: { withdrawal.amount = Double($0) ?? 0 }
            ))
                .keyboardType(.decimalPad)
            
            TextField("ID Déposé", text: $withdrawal.id_deposited_game)
            
            TextField("ID Seller", text: $withdrawal.id_seller)
            
            TextField("ID Session", text: Binding(
                get: { String(withdrawal.id_session) },
                set: { withdrawal.id_session = Int($0) ?? 0 }
            ))
                .keyboardType(.numberPad)
            
            // You may later add an interface for editing games_withdrawed.
            Button("Modifier Retrait") {
                Task {
                    await viewModel.updateWithdrawal(withdrawal: withdrawal)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Retrait")
    }
}
