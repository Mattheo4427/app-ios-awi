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
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Client")
    }
}
