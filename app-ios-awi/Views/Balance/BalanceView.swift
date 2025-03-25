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
                    Text("Bilan de la \(session.name)")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    List {
                        Section(header: Text("Ventes")) {
                            if viewModel.sales.isEmpty {
                                Text("Aucune vente enregistrée.")
                                    .foregroundStyle(.gray)
                            } else {
                                // ForEach(viewModel.sales, id: \.id_sale) { sale in SaleRow(sale: sale) }
                                Text("Nombre de ventes: \(viewModel.totalSalesCount)")
                            }
                            Text("Total des ventes: \(viewModel.totalSalesAmount, specifier: "%.2f")€")
                            Text("Total des commissions: \(viewModel.totalCommissions, specifier: "%.2f")€")
                            Text("Ticket moyen: \(viewModel.averageTicket, specifier: "%.2f")€")
                            Text("Répartition des paiements: \(viewModel.formattedPaymentDistribution.description)")
                        }
                        
                        Section(header: Text("Dépôts")) {
                            if viewModel.deposits.isEmpty {
                                Text("Aucun dépôt enregistré.")
                                    .foregroundStyle(.gray)
                            } else {
                                // ForEach(viewModel.deposits, id: \.id_deposit) { deposit in DepositRow(deposit: deposit) }
                                Text("Nombre de dépôts: \(viewModel.totalDepositsCount)")
                            }
                            Text("Total des dépôts: \(viewModel.totalDepositsAmount, specifier: "%.2f")€")
                            Text("Total des frais: \(viewModel.totalDepositFees, specifier: "%.2f")€")
                            Text("Total des remises: \(viewModel.totalDepositDiscounts, specifier: "%.2f")€")
                            Text("Montant moyen des dépôts: \(viewModel.averageDepositAmount, specifier: "%.2f")€")
                        }
                        
                        Section(header: Text("Récupérations")) {
                            if viewModel.recovers.isEmpty {
                                Text("Aucune récupération enregistrée.")
                                    .foregroundStyle(.gray)
                            } else {
                                // ForEach(viewModel.recovers, id: \.id_recover) { recover in RecoverRow(recover: recover) }
                                Text("Nombre de récupérations: \(viewModel.totalRecoversCount)")
                            }
                            Text("Total des récupérations: \(viewModel.totalRecoversAmount, specifier: "%.2f")€")
                        }
                    }
                    .listStyle(.grouped)
                } else if viewModel.userType == .seller {
                    List {
                        Section(header: Text("Ventes")) {
                            if viewModel.sales.isEmpty {
                                Text("Aucune vente enregistrée.")
                                    .foregroundStyle(.gray)
                            } else {
                                // ForEach(viewModel.sales, id: \.id_sale) { sale in SaleRow(sale: sale) }
                                Text("Nombre de ventes: \(viewModel.sellerTotalSalesCount)")
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Total des ventes:")
                                    Spacer()
                                    Text("\(viewModel.sellerTotalSalesAmount, specifier: "%.2f")€")
                                        .fontWeight(.bold)
                                }
                                //HStack {
                                    //Text("Nombre de ventes:")
                                    //Spacer()
                                    //Text("\(viewModel.sellerTotalSalesCount)")
                                        //.fontWeight(.bold)
                                //}
                                HStack {
                                    Text("Total des commissions:")
                                    Spacer()
                                    Text("\(viewModel.sellerTotalCommissions, specifier: "%.2f")€")
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    Text("Ticket moyen:")
                                    Spacer()
                                    Text("\(viewModel.sellerAverageTicket, specifier: "%.2f")€")
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    Text("Répartition des paiements:")
                                    Spacer()
                                    Text(viewModel.formattedSellerPaymentDistribution.description)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.grouped)
                }
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
