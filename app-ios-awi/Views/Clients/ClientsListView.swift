//
//  ClientsListView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct ClientsListView: View {
    @StateObject var viewModel = ClientViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.clients.isEmpty {
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Aucun client trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Il n'y a actuellement aucun client enregistré dans le système.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.clients) { client in
                            NavigationLink(destination: UpdateClientView(viewModel: viewModel, client: client)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(client.firstname) \(client.lastname)")
                                        .font(.headline)
                                    
                                    Label {
                                        Text(client.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } icon: {
                                        Image(systemName: "envelope")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if !client.phone.isEmpty {
                                        Label {
                                            Text(client.phone)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } icon: {
                                            Image(systemName: "phone")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    if let address = client.address, !address.isEmpty {
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
                        .onDelete(perform: deleteClient)
                    }
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                NavigationLink(destination: CreateClientView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchClients()
            }
        }
    }
    
    func deleteClient(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let clientID = viewModel.clients[index].id_client
                await viewModel.deleteClient(clientID: clientID)
            }
        }
    }
}