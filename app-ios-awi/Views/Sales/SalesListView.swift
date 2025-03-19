//
//  SalesListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel = SaleViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.sales.isEmpty {
                    VStack {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucune vente trouvée")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucune vente enregistrée.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.sales) { sale in
                            NavigationLink(destination: UpdateSaleView(viewModel: viewModel, sale: sale)) {
                                VStack(alignment: .leading) {
                                    Text("Sale ID: \(sale.id_sale)")
                                        .font(.headline)
                                    Text("Montant: \(sale.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete(perform: deleteSale)
                    }
                }
            }
            .navigationTitle("Ventes")
            .toolbar {
                NavigationLink(destination: CreateSaleView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchSales()
            }
        }
    }
    
    func deleteSale(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let saleID = viewModel.sales[index].id_sale
                await viewModel.deleteSale(saleID: saleID)
            }
        }
    }
}
