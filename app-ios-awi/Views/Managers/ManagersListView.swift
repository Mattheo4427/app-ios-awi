//
//  ManagersListView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct ManagersListView: View {
    @StateObject var viewModel = ManagerViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.managers.isEmpty {
                    VStack {
                        Image(systemName: "briefcase.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Aucun manager trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Il n'y a actuellement aucun manager enregistré dans le système.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.managers) { manager in
                            NavigationLink(destination: UpdateManagerView(viewModel: viewModel, manager: manager)) {
                                VStack(alignment: .leading) {
                                    Text("\(manager.firstname) \(manager.lastname)")
                                        .font(.headline)
                                    Text(manager.email)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: deleteManager)
                    }
                }
            }
            .navigationTitle("Managers")
            .toolbar {
                NavigationLink(destination: CreateManagerView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchManagers()
            }
        }
    }

    func deleteManager(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let managerID = viewModel.managers[index].id_manager
                await viewModel.deleteManager(managerID: managerID)
            }
        }
    }
}
