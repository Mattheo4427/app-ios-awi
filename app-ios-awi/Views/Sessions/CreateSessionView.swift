//
//  CreateSessionView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SessionViewModel
    
    @State private var name = ""
    @State private var dateBegin = Date()
    @State private var dateEnd = Date()
    @State private var depositFees = ""
    @State private var discount = ""
    @State private var commissionFees = ""

    var body: some View {
        Form {
            TextField("Nom de la session", text: $name)
            DatePicker("Date de début", selection: $dateBegin, displayedComponents: .date)
            DatePicker("Date de fin", selection: $dateEnd, displayedComponents: .date)
            TextField("Frais de dépôt", text: $depositFees)
                .keyboardType(.decimalPad)
            TextField("Remise", text: $discount)
                .keyboardType(.decimalPad)
            TextField("Frais de commission", text: $commissionFees)
                .keyboardType(.decimalPad)
            
            Button("Créer Session") {
                Task {
                    let newSession = Session(
                        id_session: Int.random(in: 1000...9999), // Temporary ID
                        name: name,
                        date_begin: dateBegin,
                        date_end: dateEnd,
                        deposit_fees: Double(depositFees) ?? 0.0,
                        discount: Double(discount) ?? 0.0,
                        commission_fees: Double(commissionFees) ?? 0.0
                    )
                    await viewModel.createSession(session: newSession)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouvelle Session")
    }
}
