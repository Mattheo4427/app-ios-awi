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
            Section {
                TextField("Nom d'utilisateur", text: $manager.username)
                TextField("Prénom", text: $manager.firstname)
                TextField("Nom", text: $manager.lastname)
                TextField("Email", text: $manager.email)
                TextField("Téléphone", text: $manager.phone)
                TextField("Addresse", text: Binding(
                    get: { manager.address ?? "" },
                    set: { manager.address = $0.isEmpty ? nil : $0 }
                ))
                Toggle("Admin", isOn: $manager.is_admin)
            }
            
            Button("Modifier Manager") {
                Task {
                    await viewModel.updateManager(manager: manager)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .navigationTitle("Modification Manager")
    }
}
