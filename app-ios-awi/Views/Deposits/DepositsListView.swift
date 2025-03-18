//
//  DepositsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct DepositsListView: View {
    @StateObject var viewModel = DepositViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.deposits.isEmpty {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun dépôt trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucun dépôt enregistré.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.deposits) { deposit in
                            NavigationLink(destination: UpdateDepositView(viewModel: viewModel, deposit: deposit)) {
                                VStack(alignment: .leading) {
                                    Text("Deposit ID: \(deposit.id_deposit)")
                                        .font(.headline)
                                    Text("Total: \(deposit.total_price, specifier: "%.2f")")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete(perform: deleteDeposit)
                    }
                }
            }
            .navigationTitle("Dépôts")
            .toolbar {
                NavigationLink(destination: CreateDepositView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchDeposits()
            }
        }
    }
    
    func deleteDeposit(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let depositID = viewModel.deposits[index].id_deposit
                await viewModel.deleteDeposit(depositID: depositID)
            }
        }
    }
}
