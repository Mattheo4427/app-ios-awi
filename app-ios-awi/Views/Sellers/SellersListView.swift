//
//  SellersListView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct SellersListView: View {
    @StateObject var viewModel = SellerViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.sellers.isEmpty {
                    VStack {
                        Image(systemName: "cart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Aucun vendeur trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Il n'y a actuellement aucun vendeur enregistré dans le système.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.sellers) { seller in
                            NavigationLink(destination: UpdateSellerView(viewModel: viewModel, seller: seller)) {
                                VStack(alignment: .leading) {
                                    Text("\(seller.firstname) \(seller.lastname)")
                                        .font(.headline)
                                    Text(seller.email)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteSeller)
                    }
                }
            }
            .navigationTitle("Vendeurs")
            .toolbar {
                NavigationLink(destination: CreateSellerView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchSellers()
            }
        }
    }

    func deleteSeller(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let sellerID = viewModel.sellers[index].id_seller
                await viewModel.deleteSeller(sellerID: sellerID)
            }
        }
    }
}
