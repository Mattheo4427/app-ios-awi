//
//  SellersListView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct SellersListView: View {
    @StateObject var viewModel = SellerViewModel()
    @State private var showDeleteAlert = false
    @State private var sellerToDelete: String?  // Changed from Int? to String?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.sellers.isEmpty {
                    VStack {
                        Image(systemName: "cart.fill")
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
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(seller.username)
                                        .font(.headline)
                                    
                                    Text("\(seller.firstname) \(seller.lastname)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    Label {
                                        Text(seller.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } icon: {
                                        Image(systemName: "envelope")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if let phone = seller.phone, !phone.isEmpty {
                                        Label {
                                            Text(phone)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } icon: {
                                            Image(systemName: "phone")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    if let address = seller.address, !address.isEmpty {
                                        Label {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        } icon: {
                                            Image(systemName: "mappin.and.ellipse")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .onDelete(perform: confirmDelete)
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
            .alert("Supprimer le vendeur", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let sellerID = sellerToDelete {
                        Task {
                            await viewModel.deleteSeller(sellerID: sellerID)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer ce vendeur ? Cette action est irréversible.")
            }
        }
    }

    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            sellerToDelete = viewModel.sellers[index].id_seller
            showDeleteAlert = true
        }
    }
} 