//
//  WithdrawalsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct WithdrawalsListView: View {
    @StateObject var viewModel = WithdrawalViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.withdrawals.isEmpty {
                    VStack {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun retrait trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucun retrait enregistré.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.withdrawals) { withdrawal in
                            NavigationLink(destination: UpdateWithdrawalView(viewModel: viewModel, withdrawal: withdrawal)) {
                                VStack(alignment: .leading) {
                                    Text("Withdrawal ID: \(withdrawal.id_withdrawal)")
                                        .font(.headline)
                                    Text("Montant: \(withdrawal.amount, specifier: "%.2f")")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete(perform: deleteWithdrawal)
                    }
                }
            }
            .navigationTitle("Withdrawals")
            .toolbar {
                NavigationLink(destination: CreateWithdrawalView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchWithdrawals()
            }
        }
    }
    
    func deleteWithdrawal(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let withdrawalID = viewModel.withdrawals[index].id_withdrawal
                await viewModel.deleteWithdrawal(withdrawalID: withdrawalID)
            }
        }
    }
}
