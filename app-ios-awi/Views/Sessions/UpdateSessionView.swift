//
//  UpdateSessionView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SessionViewModel
    @State var session: Session

    var body: some View {
        Form {
            TextField("Nom de la session", text: $session.name)
            DatePicker("Date de début", selection: $session.date_begin, displayedComponents: .date)
            DatePicker("Date de fin", selection: $session.date_end, displayedComponents: .date)
            TextField("Frais de dépôt ($)", text: $session.deposit_fees)
                .keyboardType(.decimalPad)
            TextField("Remise (%)", text: $session.discount)
                .keyboardType(.decimalPad)
            TextField("Frais de commission ($)", text: $session.comission_fees)
                .keyboardType(.decimalPad)

            Button("Modifier Session") {
                Task {
                    await viewModel.updateSession(session: session)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Session")
    }
}