//
//  UpdateSaleView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateSaleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SaleViewModel
    @State var sale: Sale

    var body: some View {
        Form {
            DatePicker("Date", selection: Binding(
                get: { sale.date ?? Date() },
                set: { sale.date = $0 }
            ), displayedComponents: .date)
            
            TextField("Montant", text: Binding(
                get: { String(sale.amount) },
                set: { sale.amount = Double($0) ?? 0 }
            ))
                .keyboardType(.decimalPad)
            
            TextField("Commission", text: Binding(
                get: { String(sale.comission) },
                set: { sale.comission = Double($0) ?? 0 }
            ))
                .keyboardType(.decimalPad)
            
            TextField("Méthode de paiement", text: $sale.payment_method)
            TextField("ID Seller", text: $sale.id_seller)
            
            TextField("ID Client", text: Binding(
                get: { String(sale.id_client) },
                set: { sale.id_client = Int($0) ?? 0 }
            ))
                .keyboardType(.numberPad)
            
            TextField("ID Session", text: Binding(
                get: { String(sale.id_session) },
                set: { sale.id_session = Int($0) ?? 0 }
            ))
                .keyboardType(.numberPad)
            
            TextField("ID Game", text: Binding(
                get: { String(sale.id_game) },
                set: { sale.id_game = Int($0) ?? 0 }
            ))
                .keyboardType(.numberPad)
            
            TextField("Quantité", text: Binding(
                get: { String(sale.quantity) },
                set: { sale.quantity = Int($0) ?? 0 }
            ))
                .keyboardType(.numberPad)
            
            // Optionally add UI for editing games_sold.
            Button("Modifier Vente") {
                Task {
                    await viewModel.updateSale(sale: sale)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Modification Vente")
    }
}
