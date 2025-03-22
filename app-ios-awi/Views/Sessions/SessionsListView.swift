//
//  SessionsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct SessionsListView: View {
    @StateObject var viewModel = SessionViewModel()
    @State private var showDeleteAlert = false
    @State private var sessionToDelete: Int?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.sessions.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Aucune session trouvée")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Il n'y a actuellement aucune session enregistrée dans le système.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.sessions) { session in
                            NavigationLink(destination: UpdateSessionView(viewModel: viewModel, session: session)) {
                                VStack(alignment: .leading) {
                                    Text(session.name)
                                        .font(.headline)
                                    Text("Début: \(formattedDate(session.date_begin))")
                                        .foregroundColor(.gray)
                                    Text("Fin: \(formattedDate(session.date_end))")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onDelete(perform: confirmDelete)
                    }
                }
            }
            .navigationTitle("Sessions")
            .toolbar {
                NavigationLink(destination: CreateSessionView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchSessions()
            }
            .alert("Supprimer la session", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let sessionID = sessionToDelete {
                        Task {
                            await viewModel.deleteSession(sessionID: sessionID)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cette session ? Cette action est irréversible.")
            }
        }
    }

    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            sessionToDelete = viewModel.sessions[index].id_session
            showDeleteAlert = true
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}