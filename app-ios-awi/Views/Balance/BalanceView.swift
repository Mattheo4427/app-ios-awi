//
//  BalanceView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct BalanceView: View {
    @StateObject private var viewModel = BalanceViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if let session = viewModel.sessionBalance, viewModel.userType == .manager {
                    Text("Bilan de la session \(session.id_session)")
                        .font(.headline)
                        .padding(.top, 10)
                }

                List {
                    Section(header: Text("Ventes")) {
                        if viewModel.sales.isEmpty {
                            Text("Aucune vente enregistrée.")
                                .foregroundStyle(.gray)
                        } else {
                            ForEach(viewModel.sales, id: \.id_sale) { sale in
                                SaleRow(sale: sale)
                            }
                        }
                    }

                    Section(header: Text("Dépôts")) {
                        if viewModel.deposits.isEmpty {
                            Text("Aucun dépôt enregistré.")
                                .foregroundStyle(.gray)
                        } else {
                            ForEach(viewModel.deposits, id: \.id_deposit) { deposit in
                                DepositRow(deposit: deposit)
                            }
                        }
                    }

                    Section(header: Text("Récupérations")) {
                        if viewModel.recovers.isEmpty {
                            Text("Aucune récupération enregistrée.")
                                .foregroundStyle(.gray)
                        } else {
                            ForEach(viewModel.recovers, id: \.id_recover) { recover in
                                RecoverRow(recover: recover)
                            }
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle("Bilan")
            .onAppear {
                viewModel.checkAuthState()
                Task {
                    await viewModel.fetchProfile()
                    await viewModel.fetchBalance()
                }
            }
        }
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView()
    }
}
