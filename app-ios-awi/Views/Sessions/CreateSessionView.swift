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
    @State private var comissionFees = ""

    var body: some View {
        Form {
            Section(header: Text("Informations générales")) {
                VStack(alignment: .leading) {
                    Text("Nom de la session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $name)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Dates")) {
                VStack(alignment: .leading) {
                    Text("Date de début")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $dateBegin, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Date de fin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $dateEnd, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Paramètres financiers")) {
                VStack(alignment: .leading) {
                    Text("Frais de dépôt ($)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Montant", text: $depositFees)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Remise (%)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Pourcentage", text: $discount)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Frais de commission ($)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Montant", text: $comissionFees)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Créer Session") {
                    Task {
                        let newSession = Session(
                            id_session: Int.random(in: 1000...9999), // Temporary ID
                            name: name,
                            date_begin: dateBegin,
                            date_end: dateEnd,
                            deposit_fees: depositFees,
                            discount: discount,
                            comission_fees: comissionFees
                        )
                        await viewModel.createSession(session: newSession)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Nouvelle Session")
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