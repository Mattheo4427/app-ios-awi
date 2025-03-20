//
//  CreateClientView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct CreateClientView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ClientViewModel
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""

    var body: some View {
        Form {
            Section(header: Text("Informations personnelles")) {
                VStack(alignment: .leading) {
                    Text("Prénom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prénom", text: $firstname)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Nom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $lastname)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Coordonnées")) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Téléphone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Téléphone", text: $phone)
                        .keyboardType(.phonePad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Adresse", text: $address)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button("Créer Client") {
                    Task {
                        let newClient = Client(
                            id_client: Int.random(in: 1000...9999),
                            firstname: firstname,
                            lastname: lastname,
                            email: email,
                            phone: phone,
                            address: address.isEmpty ? nil : address
                        )
                        await viewModel.createClient(client: newClient)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Nouveau Client")
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