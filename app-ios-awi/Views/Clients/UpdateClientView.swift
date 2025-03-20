//
//  UpdateClientView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct UpdateClientView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ClientViewModel
    @State var client: Client

    var body: some View {
        Form {
            Section(header: Text("Informations personnelles")) {
                VStack(alignment: .leading) {
                    Text("Prénom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prénom", text: $client.firstname)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Nom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $client.lastname)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Coordonnées")) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $client.email)
                        .keyboardType(.emailAddress)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Téléphone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Téléphone", text: $client.phone)
                        .keyboardType(.phonePad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Adresse", text: Binding(
                        get: { client.address ?? "" },
                        set: { client.address = $0.isEmpty ? nil : $0 }
                    ))
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Modifier Client") {
                    Task {
                        await viewModel.updateClient(client: client)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Modification Client")
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