//
//  CreateSaleView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateSaleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SaleViewModel
    
    @State private var date = Date()
    @State private var amount = ""
    @State private var comission = ""
    @State private var paymentMethod = ""
    @State private var idSeller = ""
    @State private var idClient = ""
    @State private var idSession = ""
    @State private var idGame = ""
    @State private var quantity = ""
    
    var body: some View {
        Form {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            TextField("Montant", text: $amount)
                .keyboardType(.decimalPad)
            TextField("Comission", text: $comission)
                .keyboardType(.decimalPad)
            TextField("Méthode de paiement", text: $paymentMethod)
            TextField("ID Seller", text: $idSeller)
            TextField("ID Client", text: $idClient)
                .keyboardType(.numberPad)
            TextField("ID Session", text: $idSession)
                .keyboardType(.numberPad)
            TextField("ID Game", text: $idGame)
                .keyboardType(.numberPad)
            TextField("Quantité", text: $quantity)
                .keyboardType(.numberPad)
            
            Button("Créer Vente") {
                Task {
                    let newSale = Sale(
                        id_sale: UUID().uuidString, // Temporary ID
                        date: date,
                        amount: Double(amount) ?? 0,
                        comission: Double(comission) ?? 0,
                        payment_method: paymentMethod,
                        id_seller: idSeller,
                        id_client: Int(idClient) ?? 0,
                        id_session: Int(idSession) ?? 0,
                        id_game: Int(idGame) ?? 0,
                        quantity: Int(quantity) ?? 0,
                        games_sold: [] // Extend UI to add sold games if needed
                    )
                    await viewModel.createSale(sale: newSale)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouvelle Vente")
    }
}

struct CreateSaleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateSaleView(viewModel: SaleViewModel())
        }
    }
}
