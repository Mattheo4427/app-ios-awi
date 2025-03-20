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
                        Image(systemName: "briefcase.fill")
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
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(manager.username)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        // Admin badge
                                        if manager.is_admin {
                                            Text("Admin")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.2))
                                                .foregroundColor(.blue)
                                                .cornerRadius(4)
                                        }
                                    }
                                    
                                    Text("\(manager.firstname) \(manager.lastname)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 12) {
                                        Label {
                                            Text(manager.email)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } icon: {
                                            Image(systemName: "envelope")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        if let phone = manager.phone, !phone.isEmpty {
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
                                    }
                                    
                                    if let address = manager.address, !address.isEmpty {
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