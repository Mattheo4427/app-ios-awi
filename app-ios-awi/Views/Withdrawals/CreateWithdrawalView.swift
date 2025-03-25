//
//  CreateWithdrawalView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateWithdrawalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WithdrawalViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var sessionViewModel = SessionViewModel()
    
    // Selected session info
    @State private var openedSession: Session?
    
    // For handling multiple games
    @State private var withdrawedGames: [EntryGame] = [EntryGame()]
    @State private var isCreatingWithdrawal = false
    @State private var isLoadingGames = false
    
    @AppStorage("authToken") private var authToken = ""

    var body: some View {
        Form {
            Section(header: Text("Informations générales")) {
                // Session display (non-editable, uses opened session)
                VStack(alignment: .leading) {
                    Text("Session")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let session = openedSession {
                        Text(session.name)
                            .foregroundColor(.primary)
                    } else {
                        Text("Chargement de la session...")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Jeux retirés")) {
                if withdrawedGames.isEmpty {
                    Text("Aucun jeu ajouté")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(withdrawedGames.indices, id: \.self) { index in
                        gameEntryView(index: index)
                    }
                }
                
                Button(action: {
                    withdrawedGames.append(EntryGame())
                }) {
                    Label("Ajouter un jeu", systemImage: "plus.circle")
                }
                .disabled(openedSession == nil)
            }
            
            // Add a summary section to show total amount
            Section(header: Text("Récapitulatif")) {
                HStack {
                    Text("Montant total:")
                    Spacer()
                    Text("\(getTotalAmount(), specifier: "%.2f") €")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            
            Section {
                Button("Créer Retrait") {
                    Task {
                        await createWithdrawal()
                    }
                }
                .disabled(!isFormValid || isCreatingWithdrawal)
                
                if isCreatingWithdrawal {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Nouveau Retrait")
        .task {
            await loadInitialData()
        }
        .alert(isPresented: Binding<Bool>(
            get: { hasError },
            set: { newValue in
                if !newValue {
                    dismissAllErrors()
                }
            }
        )) {
            Alert(
                title: Text("Erreur"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Properties
    
    func gameEntryView(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Tag du jeu (UUID)", text: $withdrawedGames[index].gameId)
                    .keyboardType(.default)
                    .padding(.vertical, 8)
                
                Button {
                    // Hide keyboard first
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // Create a Task directly
                    Task {
                        await fetchGameByTag(for: index)
                    }
                } label: {
                    Text("Confirmer")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .disabled(withdrawedGames[index].gameId.isEmpty || withdrawedGames[index].isLoading)
            }
            
            if withdrawedGames[index].isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if let game = withdrawedGames[index].gameInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.headline)
                    
                    Text("Prix: \(withdrawedGames[index].price, specifier: "%.2f") €")
                        .foregroundColor(.green)
                        .font(.subheadline)
                        .padding(.top, 2)
                    
                    // Quantity is always 1 for tags
                    Text("Quantité: 1")
                        .font(.subheadline)
                        .padding(.top, 2)
                    
                    // Display deposited game ID (tag) with copy indication
                    if let depositedId = withdrawedGames[index].depositedGameId {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ID du jeu déposé :")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(depositedId)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(6)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        .padding(.top, 4)
                    }
                    
                    Button {
                        // Remove the game
                        withdrawedGames.remove(at: index)
                        
                        // If we removed the last entry, add a new empty one
                        if withdrawedGames.isEmpty {
                            withdrawedGames.append(EntryGame())
                        }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    var isFormValid: Bool {
        guard openedSession != nil else { return false }
        
        // Check if we have at least one valid game entry
        let validGames = withdrawedGames.filter {
            $0.gameInfo != nil && $0.depositedGameId != nil
        }
        
        return !validGames.isEmpty
    }
    
    var hasError: Bool {
        return viewModel.errorMessage != nil ||
               gameViewModel.errorMessage != nil ||
               sessionViewModel.errorMessage != nil
    }
    
    var errorMessage: String {
        if let message = viewModel.errorMessage { return message }
        if let message = gameViewModel.errorMessage { return message }
        if let message = sessionViewModel.errorMessage { return message }
        return "Une erreur s'est produite"
    }
    
    // MARK: - Methods
    
    private func loadInitialData() async {
        // Clear the tags storage at the beginning of a new withdrawal
        GameTagsStorage.shared.clearTags()
        
        // Fetch session and games in parallel
        async let _ = await fetchOpenedSession()
        async let _ = await gameViewModel.fetchGames()
        
        // Wait for all tasks to complete
        await withTaskGroup(of: Void.self) { _ in }
    }
    
    private func fetchOpenedSession() async {
        do {
            if let sessionData = try await fetchData(from: "sessions/opened", reqMethod: "GET", token: authToken),
               let session: Session = decodeJSON(from: sessionData, as: Session.self) {
                
                DispatchQueue.main.async {
                    self.openedSession = session
                }
            }
        } catch {
            print("Error fetching opened session: \(error)")
            DispatchQueue.main.async {
                self.sessionViewModel.errorMessage = "Impossible de récupérer la session ouverte"
            }
        }
    }
    
    private func fetchGameByTag(for index: Int) async {
        // Get the tag
        let tag = withdrawedGames[index].gameId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if tag.isEmpty {
            DispatchQueue.main.async {
                viewModel.errorMessage = "Le tag du jeu ne peut pas être vide."
                self.withdrawedGames[index].isLoading = false
            }
            return
        }
        
        DispatchQueue.main.async {
            self.withdrawedGames[index].isLoading = true
        }
        
        do {
            // 1. Fetch the deposited game using its tag
            let depositedGameEndpoint = "deposited-game/tag/\(tag)"
            let depositedGameData = try await fetchData(from: depositedGameEndpoint, reqMethod: "GET", token: authToken)
            guard let depositedGame: DepositedGame = decodeJSON(from: depositedGameData, as: DepositedGame.self) else {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Jeu déposé non trouvé ou données invalides."
                    self.withdrawedGames[index].isLoading = false
                }
                return
            }
            
            // Check if game is already sold
            if depositedGame.sold {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Ce jeu a déjà été vendu."
                    self.withdrawedGames[index].isLoading = false
                }
                return
            }
            
            // 2. Fetch the game details using the numeric game ID from the deposited game
            let gameId = depositedGame.id_game
            let gameEndpoint = "game/\(gameId)"
            
            let gameData = try await fetchData(from: gameEndpoint, reqMethod: "GET", token: authToken)
            guard let game: Game = decodeJSON(from: gameData, as: Game.self) else {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Détails du jeu non trouvés."
                    self.withdrawedGames[index].isLoading = false
                }
                return
            }
            
            // 3. Update UI with all information
            DispatchQueue.main.async {
                self.withdrawedGames[index].gameInfo = game
                self.withdrawedGames[index].depositedGameId = tag
                self.withdrawedGames[index].gameIdNumeric = gameId
                self.withdrawedGames[index].sellerId = depositedGame.idSeller
                self.withdrawedGames[index].quantity = 1
                
                // Use the price from the depositedGame
                if let priceValue = Double(depositedGame.price) {
                    self.withdrawedGames[index].price = priceValue
                }
                
                self.withdrawedGames[index].isLoading = false
            }
            
        } catch let error as NetworkError {
            var errorMsg = "Erreur réseau"
            
            switch error {
            case .invalidURL:
                errorMsg = "URL invalide"
            case .invalidMethod:
                errorMsg = "Méthode invalide"
            case .requestFailed(let statusCode, let message):
                errorMsg = "Erreur \(statusCode): \(message ?? "Inconnue")"
            case .noData:
                errorMsg = "Aucune donnée reçue"
            case .decodingError(let message):
                errorMsg = "Erreur de décodage: \(message)"
            }
            
            DispatchQueue.main.async {
                viewModel.errorMessage = errorMsg
                self.withdrawedGames[index].isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                viewModel.errorMessage = "Erreur: \(error.localizedDescription)"
                self.withdrawedGames[index].isLoading = false
            }
        }
    }
    
    private func getTotalAmount() -> Double {
        return withdrawedGames.reduce(0.0) { $0 + $1.price }
    }
    
    private func dismissAllErrors() {
        DispatchQueue.main.async {
            viewModel.dismissError()
            gameViewModel.dismissError()
            sessionViewModel.dismissError()
        }
    }
    
    private func createWithdrawal() async {
        guard let session = openedSession else {
            viewModel.errorMessage = "La session n'est pas disponible"
            return
        }
        
        // Filter only valid games
        let validGames = withdrawedGames.filter { $0.gameInfo != nil && $0.depositedGameId != nil && $0.sellerId != nil }
        
        if validGames.isEmpty {
            viewModel.errorMessage = "Veuillez ajouter au moins un jeu valide"
            return
        }
        
        // Group games by seller
        var gamesBySeller: [String: [EntryGame]] = [:]
        for game in validGames {
            if let sellerId = game.sellerId {
                if gamesBySeller[sellerId] == nil {
                    gamesBySeller[sellerId] = []
                }
                gamesBySeller[sellerId]?.append(game)
            }
        }
        
        // Check if we have games from multiple sellers
        if gamesBySeller.count > 1 {
            viewModel.errorMessage = "Les jeux à retirer doivent appartenir au même vendeur"
            return
        }
        
        isCreatingWithdrawal = true
        
        // Get the seller ID (there should be only one)
        guard let sellerId = gamesBySeller.keys.first,
              let sellerGames = gamesBySeller[sellerId] else {
            viewModel.errorMessage = "Impossible de déterminer le vendeur"
            isCreatingWithdrawal = false
            return
        }
        
        // Calculate the total amount
        let amount = sellerGames.reduce(0.0) { $0 + $1.price }
        
        // Create withdrawal items for API
        var gamesForAPI: [GamesWithdrawed] = []
        
        // Create a map to group by game ID
        var gameIdToTagsMap: [Int: [String]] = [:]
        
        // Group the tags by game ID
        for game in sellerGames {
            if let gameId = game.gameIdNumeric, let tag = game.depositedGameId {
                if gameIdToTagsMap[gameId] == nil {
                    gameIdToTagsMap[gameId] = []
                }
                gameIdToTagsMap[gameId]?.append(tag)
            }
        }
        
        // Create GamesWithdrawed objects with proper quantities
        for (gameId, tags) in gameIdToTagsMap {
            let gameWithdrawed = GamesWithdrawed(id_game: gameId, quantity: tags.count)
            GameTagsStorage.shared.setTags(tags, for: gameWithdrawed)
            gamesForAPI.append(gameWithdrawed)
        }
        
        let newWithdrawal = Withdrawal(
            id_recover: "0", // Let backend generate the ID
            date: Date(),
            amount: amount,
            id_seller: sellerId,
            id_session: session.id_session,
            id_manager: nil, // Server will set this
            games_recovered: gamesForAPI
        )
        
        do {
            try await viewModel.createWithdrawal(withdrawal: newWithdrawal)
            
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            // Handle any errors
            print("Error creating withdrawal: \(error)")
            viewModel.errorMessage = "Erreur lors de la création du retrait: \(error.localizedDescription)"
        }
        
        DispatchQueue.main.async {
            self.isCreatingWithdrawal = false
        }
    }
}

// Add a struct to represent game entries
struct EntryGame: Identifiable {
    var id = UUID()
    var gameId: String = "" // Tag that user enters
    var depositedGameId: String? // Confirmed tag
    var gameIdNumeric: Int? // Numeric game ID
    var gameInfo: Game? // The game details
    var sellerId: String? // ID of the seller who owns this game
    var quantity: Int = 1
    var price: Double = 0.0
    var isLoading: Bool = false
}
