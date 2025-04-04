//
//  WithdrawalsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct WithdrawalsListView: View {
    @StateObject var viewModel = WithdrawalViewModel()
    @StateObject var sellerViewModel = SellerViewModel()
    @StateObject var sessionViewModel = SessionViewModel()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Chargement des retraits...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.withdrawals.isEmpty {
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
                            WithdrawalRowView(
                                withdrawal: withdrawal,
                                sellerName: getSellerName(for: withdrawal.id_seller),
                                sessionName: getSessionName(for: withdrawal.id_session)
                            )
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deleteWithdrawal)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .navigationTitle("Retraits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateWithdrawalView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await refreshData()
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func refreshData() async {
        isLoading = true
        
        do {
            // Use a Task group to cancel all tasks if one fails
            try await withThrowingTaskGroup(of: Void.self) { group in
                // Add all the fetch tasks to the group
                group.addTask {
                    await viewModel.fetchWithdrawals()
                }
                
                group.addTask {
                    await sellerViewModel.fetchSellers()
                }
                
                group.addTask {
                    await sessionViewModel.fetchSessions()
                }
                
                // Wait for all tasks to complete or one to throw
                for try await _ in group { }
            }
            
            // Check for errors after all tasks complete
            if let error = viewModel.errorMessage {
                throw NSError(domain: "WithdrawalFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            if let error = sellerViewModel.errorMessage {
                throw NSError(domain: "SellerFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            if let error = sessionViewModel.errorMessage {
                throw NSError(domain: "SessionFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: error])
            }
            
            // After fetching all withdrawals, fetch each one individually to get detailed information
            if !viewModel.withdrawals.isEmpty {
                // Create a copy of the IDs to avoid modifying the array during iteration
                let withdrawalIDs = viewModel.withdrawals.map { $0.id_recover }
                
                for id in withdrawalIDs {
                    await viewModel.fetchWithdrawalDetails(id: id)
                    
                    // Check for errors after each individual fetch
                    if let error = viewModel.errorMessage {
                        print("Error fetching details for withdrawal \(id): \(error)")
                        // Continue with other withdrawals even if one fails
                    }
                }
            }
        } catch {
            // Handle errors
            print("Failed to fetch data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func deleteWithdrawal(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let withdrawalID = viewModel.withdrawals[index].id_recover
                await viewModel.deleteWithdrawal(withdrawalID: withdrawalID)
            }
        }
    }
    
    private func getSellerName(for sellerID: String) -> String {
        if let seller = sellerViewModel.sellers.first(where: { $0.id_seller == sellerID }) {
            return "\(seller.firstname) \(seller.lastname)"
        }
        return "Vendeur #\(sellerID)"
    }
    
    private func getSessionName(for sessionID: Int) -> String {
        if let session = sessionViewModel.sessions.first(where: { $0.id_session == sessionID }) {
            return session.name
        }
        return "Session #\(sessionID)"
    }
}

struct WithdrawalRowView: View {
    let withdrawal: Withdrawal
    let sellerName: String
    let sessionName: String
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top header section - matching deposit style
            HStack {
                // Convert Substring to String with "Retrait #" prefix
                Text("Retrait #\(String(withdrawal.id_recover.prefix(8)))")
                    .font(.headline)
                
                Spacer()
                
                Text("\(withdrawal.amount, specifier: "%.2f") €")
                    .font(.headline)
                    .foregroundColor(.green) // Keep green for consistency with other withdrawal views
            }
            
            // Date on a second line - matching deposit style
            Text("Date: \(formattedDate(withdrawal.date))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Seller information
            Text(sellerName)
                .font(.title3)
                .fontWeight(.bold)
            
            // Session information
            Label(sessionName, systemImage: "calendar")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Games list
            if withdrawal.games_recovered.isEmpty {
                Text("Aucun jeu retiré")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(totalGamesCount(withdrawal.games_recovered)) jeux retirés:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(withdrawal.games_recovered, id: \.id_game) { game in
                        HStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 6, height: 6)
                            
                            Text(getGameName(for: game.id_game))
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("x\(game.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 4)
                    }
                }
            }
        }
        .padding(.vertical, 6) // Consistent padding with deposit view
        .onAppear {
            Task {
                await gameViewModel.fetchGames()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func totalGamesCount(_ games: [GamesWithdrawed]) -> Int {
        games.reduce(0) { $0 + $1.quantity }
    }
    
    private func getGameName(for gameId: Int) -> String {
        if let game = gameViewModel.games.first(where: { $0.id_game == gameId }) {
            return game.name
        }
        return "Jeu #\(gameId)"
    }
}
