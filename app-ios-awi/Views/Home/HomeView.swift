//
//  HomeView.swift
//  app-ios-awi
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("userRole") private var userRole = "client"
    
    // Check if user has manager privileges
    private var isManager: Bool {
        userRole == "admin" || userRole == "manager"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Chargement du catalogue...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Erreur")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    .padding()
                } else if viewModel.mergedGames.isEmpty {
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Catalogue vide")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Aucun jeu n'est disponible pour le moment.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 4)
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchCatalogue()
                            }
                        }) {
                            Text("Actualiser")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.mergedGames) { mergedGame in
                            // For managers, wrap in NavigationLink to show detailed view 
                            // For regular users, just show the game info
                            if isManager {
                                NavigationLink(destination: MergedGameDetailView(viewModel: viewModel, mergedGame: mergedGame)) {
                                    GameCatalogItem(mergedGame: mergedGame, viewModel: viewModel, isManager: isManager)
                                }
                            } else {
                                GameCatalogItem(mergedGame: mergedGame, viewModel: viewModel, isManager: isManager)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Catalogue", displayMode: .inline)
            .onAppear {
                // Set manager status in view model when view appears
                viewModel.isManager = isManager
                
                Task {
                    await viewModel.fetchCatalogue()
                }
            }
            .refreshable {
                await viewModel.fetchCatalogue()
            }
        }
    }
}

// Update the GameCatalogItem view to accept isManager parameter
struct GameCatalogItem: View {
    let mergedGame: MergedGame
    @ObservedObject var viewModel: HomeViewModel
    let isManager: Bool
    
    // Calculate detailed statistics for managers
    private var gameStats: (available: Int, sold: Int, reserved: Int) {
        let games = viewModel.allDepositedGames.filter {
            $0.id_game == mergedGame.gameId &&
            $0.price == mergedGame.price &&
            $0.idSeller == mergedGame.sellerId
        }
        
        let available = games.filter { $0.forSale && !$0.sold }.count
        let sold = games.filter { $0.sold }.count
        let reserved = games.filter { !$0.forSale && !$0.sold }.count
        
        return (available, sold, reserved)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let gameDetails = mergedGame.gameDetails {
                HStack(alignment: .top, spacing: 12) {
                    // Game image
                    AsyncImage(url: URL(string: gameDetails.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                        @unknown default:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameDetails.name)
                            .font(.headline)
                        
                        HStack {
                            Text("👥 \(gameDetails.min_players)-\(gameDetails.max_players)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("📅 \(gameDetails.min_age)-\(gameDetails.max_age) ans")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        if let description = gameDetails.description {
                            Text(description)
                                .lineLimit(2)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer().frame(height: 8)
                        
                        HStack {
                            Text("💰 \(mergedGame.price)€")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            // Different display for managers vs regular users
                            if isManager {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("📦 \(gameStats.available) disponible\(gameStats.available > 1 ? "s" : "")")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    
                                    Text("🛒 \(gameStats.sold) vendu\(gameStats.sold > 1 ? "s" : "")")
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                    
                                    Text("📋 \(gameStats.reserved) en réserve")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Text("📦 \(mergedGame.count) disponible\(mergedGame.count > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            } else {
                // Loading placeholder
                HStack {
                    // Empty image placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 20)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                            .cornerRadius(4)
                        
                        Spacer().frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 60, height: 20)
                            .cornerRadius(4)
                    }
                    .padding(.leading, 4)
                }
                .redacted(reason: .placeholder)
            }
        }
        .padding(.vertical, 8)
    }
}

// Add the MergedGameDetailView
struct MergedGameDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    let mergedGame: MergedGame
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var sellerViewModel = SellerViewModel()
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var copiedTag: String? = nil
    
    // Get the individual deposited games for this merged game
    private var individualGames: [DepositedGame] {
        return viewModel.allDepositedGames.filter {
            !$0.sold &&
            $0.id_game == mergedGame.gameId &&
            $0.price == mergedGame.price &&
            $0.idSeller == mergedGame.sellerId
        }
    }
    
    var body: some View {
        List {
            // Game info header
            Section {
                if let gameDetails = mergedGame.gameDetails {
                    HStack(alignment: .top, spacing: 12) {
                        // Game image
                        AsyncImage(url: URL(string: gameDetails.image ?? "")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            case .failure, _:
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(gameDetails.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Prix: \(mergedGame.price)€")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            if let description = gameDetails.description {
                                Text(description)
                                    .lineLimit(3)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    Text("Jeu #\(mergedGame.gameId)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            
            // Individual games section
            Section(header: Text("Exemplaires disponibles")) {
                if individualGames.isEmpty {
                    Text("Aucun exemplaire disponible")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(individualGames, id: \.tag) { game in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    // Copiable ID with visual feedback
                                    HStack(spacing: 4) {
                                        Text("ID: ")
                                            .font(.headline)
                                            
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
                                    }
                                    
                                    let sellerName = getSellerFullName(for: game.idSeller)
                                    Text("Vendeur: \(sellerName)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Status badge
                                Text(game.forSale ? "En vente" : "Non en vente")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(game.forSale ? Color.green : Color.orange)
                                    .cornerRadius(8)
                            }
                            
                            // Toggle button
                            Button(action: {
                                Task {
                                    let success = await viewModel.toggleForSaleStatus(for: game)
                                    alertMessage = success ? "Statut mis à jour" : "Échec de la mise à jour"
                                    showingAlert = true
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text(game.forSale ? "Retirer de la vente" : "Mettre en vente")
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(game.forSale ? Color.red.opacity(0.8) : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Gestion des exemplaires")
        .refreshable {
            Task {
                await viewModel.fetchCatalogue()
                await gameViewModel.fetchGames()
                await sellerViewModel.fetchSellers()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Mise à jour"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
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
        )
        .onAppear {
            Task {
                await gameViewModel.fetchGames()
                await sellerViewModel.fetchSellers()
            }
        }
    }
    
    // Helper function to get seller's full name from ID
    private func getSellerFullName(for sellerId: String) -> String {
        if let seller = sellerViewModel.sellers.first(where: { $0.id_seller == sellerId }) {
            return "\(seller.firstname) \(seller.lastname)"
        }
        return sellerId
    }
    
    // Function to copy tag to clipboard
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
}
