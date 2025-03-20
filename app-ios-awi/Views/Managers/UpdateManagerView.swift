//
// UpdateManagerView.swift
// app-ios-awi
//
// Created by etud on 17/03/2025.

import SwiftUI

struct UpdateManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ManagerViewModel
    @State var manager: Manager

    var body: some View {
        Form {
            Section(header: Text("Compte")) {
                VStack(alignment: .leading) {
                    Text("Nom d'utilisateur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom d'utilisateur", text: $manager.username)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Informations personnelles")) {
                VStack(alignment: .leading) {
                    Text("Prénom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prénom", text: $manager.firstname)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Nom")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Nom", text: $manager.lastname)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Coordonnées")) {
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Email", text: $manager.email)
                        .keyboardType(.emailAddress)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Téléphone")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Téléphone", text: $manager.phone)
                        .keyboardType(.phonePad)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Adresse", text: Binding(
                        get: { manager.address ?? "" },
                        set: { manager.address = $0.isEmpty ? nil : $0 }
                    ))
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Permissions")) {
                Toggle("Droits administrateur", isOn: Binding(
                    get: { manager.is_admin },
                    set: { manager.is_admin = $0 }
                ))
            }
            
            Section {
                Button("Modifier Manager") {
                    Task {
                        await viewModel.updateManager(manager: manager)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Modification Manager")
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