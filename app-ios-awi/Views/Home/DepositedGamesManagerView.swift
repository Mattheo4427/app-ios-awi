//
//  DepositedGamesManagerView.swift
//  app-ios-awi
//
//  Created by etud on 25/03/2025.
//

import SwiftUI

struct DepositedGamesManagerView: View {
    @ObservedObject var viewModel: HomeViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var sellerViewModel = SellerViewModel()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var copiedTag: String? = nil
    @State private var searchText = ""
    
    // Show all games (not just unsold ones), filtered by search text if provided
    private var allGames: [DepositedGame] {
        let games = viewModel.allDepositedGames
        if searchText.isEmpty {
            return games
        } else {
            return games.filter { game in
                game.tag.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack {
            // Enhanced search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .padding(.leading, 8)
                
                TextField("Rechercher par ID...", text: $searchText)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.vertical, 10)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    .background(Color(.systemGray6).cornerRadius(10))
            )
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Game list
            List {
                if allGames.isEmpty {
                    if searchText.isEmpty {
                        emptyStateView
                    } else {
                        Text("Aucun jeu trouvé pour '\(searchText)'")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    gameListContent
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Gestion des jeux")
        .refreshable {
            await refreshData()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Mise à jour"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(loadingOverlay)
        .onAppear {
            Task {
                await gameViewModel.fetchGames()
                await sellerViewModel.fetchSellers()
            }
        }
    }
    
    // Extracted empty state view
    private var emptyStateView: some View {
        Text("Aucun jeu déposé")
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    // Extracted game list content
    private var gameListContent: some View {
        ForEach(allGames, id: \.tag) { game in
            gameItemView(for: game)
        }
    }
    
    // Extracted individual game item view
    private func gameItemView(for game: DepositedGame) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                gameInfoSection(for: game)
                sellerInfoSection(for: game)
                gameTagSection(for: game)
                Divider()
                toggleButtonSection(for: game)
            }
        }
        .listRowBackground(Color.clear)
    }
    
    // Extracted game info section
    private func gameInfoSection(for game: DepositedGame) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                let gameName = getGameName(for: game.id_game)
                Text(gameName)
                    .font(.headline)
                
                Text("Prix: \(game.price)€")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Text(getGameStatus(game))
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(getStatusColor(game))
                .cornerRadius(8)
        }
    }
    
    // Extracted seller info section
    private func sellerInfoSection(for game: DepositedGame) -> some View {
        HStack {
            let sellerName = getSellerFullName(for: game.idSeller)
            Text("Vendeur: \(sellerName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // Extracted game tag section
    private func gameTagSection(for game: DepositedGame) -> some View {
        HStack {
            Text("ID: ")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer().frame(width: 4)
            
            HStack(spacing: 4) {
                Text("\(game.tag)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
                
                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
            .onTapGesture {
                copyTag(game.tag)
            }
            
            if copiedTag == game.tag {
                Text("Copié!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.leading, 4)
            }
            
            Spacer()
        }
    }
    
    // Extracted toggle button section
    private func toggleButtonSection(for game: DepositedGame) -> some View {
        Group {
            if !game.sold {
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            let success = await viewModel.toggleForSaleStatus(for: game)
                            alertMessage = success ? "Statut mis à jour" : "Échec de la mise à jour"
                            showingAlert = true
                        }
                    }) {
                        Text(game.forSale ? "Retirer de la vente" : "Mettre en vente")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(game.forSale ? Color.red.opacity(0.8) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                }
            }
        }
    }
    
    // Extracted loading overlay
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView("Mise à jour...")
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                    )
            }
        }
    }
    
    // Extracted refresh data method
    private func refreshData() async {
        await viewModel.fetchCatalogue()
        await gameViewModel.fetchGames()
        await sellerViewModel.fetchSellers()
    }
    
    // Extracted tag copy method
    private func copyTag(_ tag: String) {
        UIPasteboard.general.string = tag
        copiedTag = tag
        
        // Clear the "Copied" indication after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedTag == tag {
                copiedTag = nil
            }
        }
    }
    
    // Helper functions (unchanged)
    private func getGameStatus(_ game: DepositedGame) -> String {
        if game.sold {
            return "Vendu"
        } else if game.forSale {
            return "En vente"
        } else {
            return "En réserve"
        }
    }
    
    private func getStatusColor(_ game: DepositedGame) -> Color {
        if game.sold {
            return Color.purple
        } else if game.forSale {
            return Color.green
        } else {
            return Color.orange
        }
    }
    
    private func getGameName(for gameId: Int) -> String {
        if let game = gameViewModel.games.first(where: { $0.id_game == gameId }) {
            return game.name
        }
        return "Jeu #\(gameId)"
    }
    
    private func getSellerFullName(for sellerId: String) -> String {
        if let seller = sellerViewModel.sellers.first(where: { $0.id_seller == sellerId }) {
            return "\(seller.firstname) \(seller.lastname)"
        }
        return sellerId
    }
}
