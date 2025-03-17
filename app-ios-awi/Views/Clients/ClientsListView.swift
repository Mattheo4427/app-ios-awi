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
                        Image(systemName: "person.slash")
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
                                VStack(alignment: .leading) {
                                    Text("\(client.firstname) \(client.lastname)")
                                        .font(.headline)
                                    Text(client.email)
                                        .foregroundColor(.gray)
                                }
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
