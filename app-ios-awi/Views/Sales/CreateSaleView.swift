//
//  CreateSaleView.swift
//  app-ios-awi
//
//  Created by etud on 24/03/2025.
//

import SwiftUI

struct CreateSaleView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SaleViewModel
    @StateObject private var clientViewModel = ClientViewModel()
    
    @State private var selectedClient: Client?
    @State private var gameEntries: [GameEntry] = [GameEntry()]
    @State private var paymentMethod = ""
    @State private var openedSession: Session?
    @State private var isCreatingSale = false
    @State private var gamesBySeller: [String: [GameEntry]] = [:]
    
    @AppStorage("authToken") private var authToken = ""
    
    let paymentMethods = ["Carte", "Espèces", "Virement"]
    
    // Computed property for total price
    var totalPrice: Double {
        return gameEntries.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    // Computed property for commission amount - Fixed to unwrap optional
    var commissionAmount: Double {
        guard let session = openedSession else { return 0.0 }
        let commissionPercentage = (Double(session.comission_fees) ?? 0.0) / 100.0
        return totalPrice * commissionPercentage
    }
    
    // Computed property for final price including commission
    var finalPrice: Double {
        return totalPrice + commissionAmount
    }
    
    var body: some View {
        Form {
            // Client Section
            Section(header: Text("Client")) {
                clientPicker
                
                Menu {
                    ForEach(paymentMethods, id: \.self) { method in
                        Button(method) {
                            paymentMethod = method
                        }
                    }
                } label: {
                    HStack {
                        Text(paymentMethod.isEmpty ? "Méthode de paiement" : paymentMethod)
                            .foregroundColor(paymentMethod.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                }
            }
            
            // Games Section
            Section(header: Text("Jeux")) {
                ForEach(gameEntries.indices, id: \.self) { index in
                    gameEntryView(index: index)
                }
                
                Button {
                    gameEntries.append(GameEntry())
                } label: {
                    Label("Ajouter un jeu", systemImage: "plus.circle")
                }
            }
            
            // Total Price Section
            Section(header: Text("Récapitulatif")) {
                HStack {
                    Text("Total:")
                    Spacer()
                    Text("\(totalPrice, specifier: "%.2f") €")
                        .bold()
                }
                
                if let session = openedSession {
                    HStack {
                        Text("Commission (\(session.comission_fees)%):")
                        Spacer()
                        Text("\(commissionAmount, specifier: "%.2f") €")
                    }
                    
                    HStack {
                        Text("Total à payer:")
                        Spacer()
                        Text("\(finalPrice, specifier: "%.2f") €")
                            .foregroundColor(.blue)
                            .bold()
                    }
                }
            }
            
            // Create Button
            Section {
                Button {
                    Task {
                        await createSale()
                    }
                } label: {
                    if isCreatingSale {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Créer la vente")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                }
                .disabled(!isFormValid || isCreatingSale)
            }
        }
        .navigationTitle("Nouvelle Vente")
        .onAppear {
            Task {
                await fetchInitialData()
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Alert(
                title: Text("Erreur"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var clientPicker: some View {
        Menu {
            ForEach(clientViewModel.clients) { client in
                Button("\(client.firstname) \(client.lastname)") {
                    selectedClient = client
                }
            }
        } label: {
            HStack {
                Text(selectedClient != nil ? "\(selectedClient!.firstname) \(selectedClient!.lastname)" : "Sélectionner un client")
                    .foregroundColor(selectedClient != nil ? .primary : .secondary)
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
    }
    
    func gameEntryView(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("ID du jeu déposé (UUID)", text: $gameEntries[index].gameId)
                    .keyboardType(.default)
                    .padding(.vertical, 8)
                
                Button {
                    // Hide keyboard first
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // Create a Task directly
                    Task {
                        await fetchGameByDepositedGameUUID(for: index)
                    }
                } label: {
                    Text("Confirmer")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .disabled(gameEntries[index].gameId.isEmpty || gameEntries[index].isLoading)
            }
            
            if gameEntries[index].isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if let game = gameEntries[index].gameInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.headline)
                    
                    if gameEntries[index].price > 0 {
                        Text("Prix: \(gameEntries[index].price, specifier: "%.2f") €")
                            .foregroundColor(.green)
                            .font(.subheadline)
                            .padding(.top, 2)
                    }
                    
                    // Fixed quantity display - no stepper since quantity is always 1
                    Text("Quantité: 1")
                        .font(.subheadline)
                        .padding(.top, 4)
                    
                    // Allow deleting any game, but ensure we always have at least one game entry
                    Button {
                        // Remove the game
                        gameEntries.remove(at: index)
                        
                        // If we removed the last entry, add a new empty one
                        if gameEntries.isEmpty {
                            gameEntries.append(GameEntry())
                        }
                        
                        // Update the games by seller
                        updateGamesBySeller()
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
        guard selectedClient != nil, !paymentMethod.isEmpty else { return false }
        
        // Check if we have at least one valid game entry
        let validGames = gameEntries.filter {
            $0.gameInfo != nil && $0.price > 0
        }
        
        return !validGames.isEmpty
    }
    
    func fetchInitialData() async {
        async let _ = await clientViewModel.fetchClients()
        async let _ = await fetchOpenedSession()
    }
    
    func fetchOpenedSession() async {
        do {
            if let sessionData = try await fetchData(from: "sessions/opened", reqMethod: "GET", token: authToken),
               let session: Session = decodeJSON(from: sessionData, as: Session.self) {
                DispatchQueue.main.async {
                    self.openedSession = session
                }
            }
        } catch {
            print("Error fetching session: \(error)")
        }
    }
    
    // Fixed function to properly handle DepositedGame fields
    func fetchGameByDepositedGameUUID(for index: Int) async {
        print("Starting to fetch deposited game at index: \(index)")
        
        // Get the deposited game UUID (string)
        let depositedGameId = gameEntries[index].gameId.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if depositedGameId.isEmpty {
            DispatchQueue.main.async {
                viewModel.errorMessage = "L'ID du jeu déposé ne peut pas être vide."
                self.gameEntries[index].isLoading = false
            }
            return
        }
        
        DispatchQueue.main.async {
            self.gameEntries[index].isLoading = true
        }
        
        do {
            print("Making API call to fetch deposited game with UUID: \(depositedGameId)")
            
            // 1. First fetch the deposited game using its UUID
            let depositedGameEndpoint = "deposited-game/tag/\(depositedGameId)"
            let depositedGameData = try await fetchData(from: depositedGameEndpoint, reqMethod: "GET", token: authToken)
            guard let depositedGame: DepositedGame = decodeJSON(from: depositedGameData, as: DepositedGame.self) else {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Jeu déposé non trouvé ou données invalides."
                    self.gameEntries[index].isLoading = false
                }
                return
            }
            
            // Check availability
            if depositedGame.sold {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Ce jeu a déjà été vendu."
                    self.gameEntries[index].isLoading = false
                }
                return
            }
            
            if !depositedGame.forSale {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Ce jeu n'est pas disponible à la vente."
                    self.gameEntries[index].isLoading = false
                }
                return
            }
            
            // 2. Now fetch the game details using the numeric game ID from the deposited game
            let gameId = depositedGame.id_game
            let gameEndpoint = "game/\(gameId)"
            print("Fetching game details with ID: \(gameId)")
            
            let gameData = try await fetchData(from: gameEndpoint, reqMethod: "GET", token: authToken)
            guard let game: Game = decodeJSON(from: gameData, as: Game.self) else {
                DispatchQueue.main.async {
                    viewModel.errorMessage = "Détails du jeu non trouvés."
                    self.gameEntries[index].isLoading = false
                }
                return
            }
            
            // 3. Update UI with all the information
            DispatchQueue.main.async {
                self.gameEntries[index].gameInfo = game
                self.gameEntries[index].sellerId = depositedGame.idSeller
                self.gameEntries[index].depositedGameId = depositedGameId
                
                // Set fixed quantity to 1 since each deposited game is a unique item
                self.gameEntries[index].quantity = 1
                
                // Use the price from the depositedGame if available
                if let priceValue = Double(depositedGame.price) {
                    self.gameEntries[index].price = priceValue
                } else {
                    self.gameEntries[index].price = 20.0 // Default fallback price
                }
                
                self.gameEntries[index].isLoading = false
                self.updateGamesBySeller()
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
            
            print("Network error in fetchGameByDepositedGameUUID: \(errorMsg)")
            
            DispatchQueue.main.async {
                viewModel.errorMessage = errorMsg
                self.gameEntries[index].isLoading = false
            }
        } catch {
            print("Error fetching deposited game: \(error)")
            DispatchQueue.main.async {
                viewModel.errorMessage = "Erreur: \(error.localizedDescription)"
                self.gameEntries[index].isLoading = false
            }
        }
    }
    
    func updateGamesBySeller() {
        var newGamesBySeller: [String: [GameEntry]] = [:]
        
        for game in gameEntries {
            if let sellerId = game.sellerId, game.gameInfo != nil {
                if newGamesBySeller[sellerId] == nil {
                    newGamesBySeller[sellerId] = []
                }
                newGamesBySeller[sellerId]?.append(game)
            }
        }
        
        gamesBySeller = newGamesBySeller
    }
    
    // Fixed function to handle commissions correctly and create the right GameSold objects
    func createSale() async {
        guard let client = selectedClient, let session = openedSession else { return }
        
        isCreatingSale = true
        
        // Group valid games by seller
        updateGamesBySeller()
        
        // Map the user-friendly payment method to backend format
        let backendPaymentMethod = mapPaymentMethodToBackend(paymentMethod)
        
        // Create sale for each seller
        for (sellerId, games) in gamesBySeller {
            do {
                // Create GameSold objects exactly matching the backend's expected structure
                let gamesSold = games.compactMap { game -> GameSold? in
                    guard let gameInfo = game.gameInfo, let depositedGameId = game.depositedGameId else { return nil }
                    
                    // Match the exact structure from your backend DTO
                    return GameSold(
                        id_game: gameInfo.id_game,
                        quantity: 1,
                        tags: [depositedGameId]
                    )
                }
                
                // Calculate commission amount (not percentage)
                let commissionAmount = commissionAmount  // This is the computed property that calculates the actual amount
                
                // Format date as ISO8601 string
                let dateFormatter = ISO8601DateFormatter()
                let dateString = dateFormatter.string(from: Date())
                
                // Create a dictionary to match exactly what the backend expects
                let saleData: [String: Any] = [
                    "date": dateString,         // Send date as a string
                    "amount": totalPrice,       // Send the total price calculated in the UI
                    "comission": commissionAmount,  // Send the actual commission amount, not percentage
                    "payment_method": backendPaymentMethod,
                    "id_seller": sellerId,
                    "id_client": client.id_client,
                    "id_session": session.id_session,
                    "games_sold": gamesSold.map { [
                        "id_game": $0.id_game,
                        "quantity": $0.quantity,
                        "tags": $0.tags ?? []
                    ]}
                ]
                
                // Now convert this dictionary to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: saleData, options: [.prettyPrinted])
                
                // Log the request for debugging
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Request JSON: \(jsonString)")
                }
                
                // Make the API call
                _ = try await fetchData(from: "sales", reqMethod: "POST", body: jsonData, token: authToken)
            } catch {
                print("Sale creation error: \(error)")
                viewModel.errorMessage = "Erreur: \(error.localizedDescription)"
                isCreatingSale = false
                return
            }
        }
        
        // Success - go back
        isCreatingSale = false
        presentationMode.wrappedValue.dismiss()
    }

        // Helper function to map UI payment methods to backend payment methods
        private func mapPaymentMethodToBackend(_ method: String) -> String {
            switch method {
            case "Carte":
                return "credit_card"
            case "Espèces":
                return "cash"
            case "Virement":
                return "check"
            default:
                return method.lowercased()
            }
        }
    }

struct GameEntry: Identifiable {
    var id = UUID()
    var gameId: String = "" // This is the deposited game UUID that the user enters
    var depositedGameId: String? // Store the deposited game UUID once confirmed
    var gameInfo: Game? // The actual game with numeric ID
    var quantity: Int = 1 // Always 1 since each deposited game is a unique item
    var price: Double = 0.0
    var sellerId: String?
    var isLoading: Bool = false
}

// Models needed for the API
struct DepositResponse: Codable {
    var id_deposit: String
    var id_seller: String
    var games_deposited: [GameDepositedItem]
}

struct GameDepositedItem: Codable {
    var id_game: Int
    var quantity: Int
}
