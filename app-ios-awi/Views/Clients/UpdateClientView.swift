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
            TextField("Prénom", text: $client.firstname)
            TextField("Nom", text: $client.lastname)
            TextField("Email", text: $client.email)
            TextField("Téléphone", text: $client.phone)
            TextField("Addresse", text: Binding(
                get: { client.address ?? "" },
                set: { client.address = $0.isEmpty ? nil : $0 }
            ))

            Button("Modifier Client") {
                Task {
                    await viewModel.updateClient(client: client)
                    // Only dismiss if there was no error
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
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
