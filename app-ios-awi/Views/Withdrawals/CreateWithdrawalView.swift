//
//  CreateWithdrawalView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateWithdrawalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WithdrawalViewModel
    
    // For simplicity, only a few fields are used
    @State private var date = Date()
    @State private var amount = ""
    @State private var idDepositedGame = ""
    @State private var idSeller = ""
    @State private var idSession = ""
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            TextField("Montant", text: $amount)
                .keyboardType(.decimalPad)
            TextField("ID Déposé", text: $idDepositedGame)
            TextField("ID Seller", text: $idSeller)
            TextField("ID Session", text: $idSession)
                .keyboardType(.numberPad)
            
            Button("Créer Retrait") {
                Task {
                    let newWithdrawal = Withdrawal(
                        id_withdrawal: Int.random(in: 1000...9999), // Temporary ID
                        date: date,
                        amount: Double(amount) ?? 0,
                        id_deposited_game: idDepositedGame,
                        id_seller: idSeller,
                        id_session: Int(idSession) ?? 0,
                        games_withdrawed: [] // Could add a UI to input games withdrawed details
                    )
                    await viewModel.createWithdrawal(withdrawal: newWithdrawal)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouveau Retrait")
    }
}

struct CreateWithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateWithdrawalView(viewModel: WithdrawalViewModel())
        }
    }
}
