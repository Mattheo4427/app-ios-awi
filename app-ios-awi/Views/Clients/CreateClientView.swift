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
            TextField("Prénom", text: $firstname)
            TextField("Nom", text: $lastname)
            TextField("Email", text: $email)
            TextField("Téléphone", text: $phone)
            TextField("Addresse", text: $address)

            Button("Créer Client") {
                Task {
                    let newClient = Client(
                        id_client: Int.random(in: 1000...9999), // Temporary ID
                        firstname: firstname,
                        lastname: lastname,
                        email: email,
                        phone: phone,
                        address: address.isEmpty ? nil : address
                    )
                    await viewModel.createClient(client: newClient)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouveau Client")
    }
}
