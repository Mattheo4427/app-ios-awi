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
            Section(header: Text("Informations générales")) {
                VStack(alignment: .leading) {
                    Text("Nom de la session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $session.name)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Dates")) {
                VStack(alignment: .leading) {
                    Text("Date de début")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $session.date_begin, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Date de fin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $session.date_end, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Paramètres financiers")) {
                VStack(alignment: .leading) {
                    Text("Frais de dépôt ($)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Montant", text: $session.deposit_fees)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Remise (%)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Pourcentage", text: $session.discount)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Frais de commission ($)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Montant", text: $session.comission_fees)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Modifier Session") {
                    Task {
                        await viewModel.updateSession(session: session)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Modification Session")
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