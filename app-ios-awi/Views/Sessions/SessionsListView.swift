//
//  SessionsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct SessionsListView: View {
    @StateObject var viewModel = SessionViewModel()

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
                        .onDelete(perform: deleteSession)
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
        }
    }

    func deleteSession(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let sessionID = viewModel.sessions[index].id_session
                await viewModel.deleteSession(sessionID: sessionID)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
