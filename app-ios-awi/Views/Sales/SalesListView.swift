import SwiftUI

protocol GameSoldProtocol {
    var id_game: Int { get }
    var quantity: Int { get }
    var tags: [String]? { get }
}

extension GameSold: GameSoldProtocol {}

struct SalesListView: View {
    @StateObject var viewModel = SaleViewModel()
    @StateObject var sellerViewModel = SellerViewModel()
    @StateObject var gameViewModel = GameViewModel()
    @StateObject var clientViewModel = ClientViewModel()
    @StateObject var sessionViewModel = SessionViewModel()
    @State private var showDeleteAlert = false
    @State private var saleToDelete: String?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Ventes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CreateSaleView(viewModel: viewModel)) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .task { await fetchData() }
                .refreshable {
                    isLoading = true
                    await fetchData()
                }
                .alert("Erreur", isPresented: errorBinding) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .alert("Confirmation", isPresented: $showDeleteAlert, presenting: saleToDelete) { id in
                    Button("Supprimer", role: .destructive) {
                        Task { await viewModel.deleteSale(saleID: id) }
                    }
                    Button("Annuler", role: .cancel) {}
                } message: { _ in
                    Text("Êtes-vous sûr de vouloir supprimer cette vente ?")
                }
        }
    }
    
    // MARK: - Content Views
    
    private var contentView: some View {
        Group {
            if isLoading {
                loadingView
            } else if viewModel.sales.isEmpty {
                EmptySaleStateView()
            } else {
                saleListView
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView("Chargement des données...")
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    private var saleListView: some View {
        List {
            ForEach(viewModel.sales) { sale in
                SaleRowView(
                    sale: sale,
                    sellerViewModel: sellerViewModel,
                    gameViewModel: gameViewModel,
                    clientViewModel: clientViewModel,
                    sessionViewModel: sessionViewModel
                )
            }
            .onDelete(perform: confirmDelete)
        }
    }
    
    // MARK: - Error Handling
    
    private var errorBinding: Binding<Bool> {
        Binding<Bool>(
            get: { 
                viewModel.errorMessage != nil ||
                sellerViewModel.errorMessage != nil ||
                gameViewModel.errorMessage != nil ||
                clientViewModel.errorMessage != nil ||
                sessionViewModel.errorMessage != nil 
            },
            set: { 
                if !$0 {
                    viewModel.dismissError()
                    sellerViewModel.dismissError()
                    gameViewModel.dismissError()
                    clientViewModel.dismissError()
                    sessionViewModel.dismissError()
                }
            }
        )
    }
    
    private var errorMessage: String {
        viewModel.errorMessage ??
        sellerViewModel.errorMessage ??
        gameViewModel.errorMessage ??
        clientViewModel.errorMessage ??
        sessionViewModel.errorMessage ??
        "Une erreur inconnue s'est produite."
    }
    
    // MARK: - Helper Methods
    
    private func fetchData() async {
        isLoading = true
        
        await viewModel.fetchSales()
        
        if !viewModel.sales.isEmpty {
            // First fetch all related data
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await sellerViewModel.fetchSellers() }
                group.addTask { await gameViewModel.fetchGames() }
                group.addTask { await clientViewModel.fetchClients() }
                group.addTask { await sessionViewModel.fetchSessions() }
                
                for await _ in group { }
            }
            
            // Then fetch detailed information for each sale
            let saleIDs = viewModel.sales.compactMap { $0.id_sale }
            
            for id in saleIDs {
                await viewModel.fetchSaleDetails(id: id)
                
                // Continue with other sales even if one fetch fails
                if viewModel.errorMessage != nil {
                    print("Error fetching details for sale \(id): \(viewModel.errorMessage!)")
                    viewModel.dismissError() // Clear error to continue with other sales
                }
            }
        }
        
        isLoading = false
    }
    
    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            saleToDelete = viewModel.sales[index].id_sale
            showDeleteAlert = true
        }
    }
}

// MARK: - Empty State View

struct EmptySaleStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("Aucune vente trouvée")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Il n'y a actuellement aucune vente enregistrée.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Sale Row View

struct SaleRowView: View {
    let sale: Sale
    @ObservedObject var sellerViewModel: SellerViewModel
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var clientViewModel: ClientViewModel
    @ObservedObject var sessionViewModel: SessionViewModel
    
    @State private var detailedSale: DetailedSale?
    @State private var isLoadingDetails = false
    @AppStorage("authToken") private var authToken = ""
    @State private var seller: Seller?
    @State private var client: Client?
    @State private var session: Session?
    @State private var gameLookup: [Int: Game] = [:]
    
    // Using @State properties to track data changes instead of onChange
    @State private var sellerListVersion = 0
    @State private var clientListVersion = 0
    @State private var sessionListVersion = 0
    @State private var gameListVersion = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with ID and Amount
            headerView
            
            // People involved in the sale
            peopleInfoView
            
            // Price and payment details  
            transactionDetailsView
            
            // Games list
            if !sale.games_sold.isEmpty {
                gamesSoldView
            }
        }
        .padding(.vertical, 6)
        .onAppear {
            // Safely look up related data on main thread
            lookupRelatedData()
            Task { await fetchSaleDetails() }
        }
        // Using onReceive to monitor view model changes without requiring Equatable
        .onReceive(sellerViewModel.$sellers.dropFirst()) { _ in
            sellerListVersion += 1
            lookupRelatedData()
        }
        .onReceive(clientViewModel.$clients.dropFirst()) { _ in
            clientListVersion += 1
            lookupRelatedData()
        }
        .onReceive(sessionViewModel.$sessions.dropFirst()) { _ in
            sessionListVersion += 1
            lookupRelatedData()
        }
        .onReceive(gameViewModel.$games.dropFirst()) { _ in
            gameListVersion += 1
            lookupRelatedData()
        }
    }
    
    // MARK: - Row Components
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Show "Vente #" prefix with ID
                Text("Vente #\(String(sale.id_sale?.prefix(8) ?? ""))")
                    .font(.headline)
                
                Spacer()
                
                Text("\(sale.amount, specifier: "%.2f") €")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            // Add date on a second line
            if let date = sale.date {
                Text("Date: \(formattedDate(date))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var peopleInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let date = sale.date {
                Label {
                    Text("Date: \(formattedDate(date))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.secondary)
                }
            }
            
            // Seller information
            SellerInfoView(seller: seller)
            
            // Client information
            ClientInfoView(client: client)
        }
    }
    
    private var transactionDetailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if sale.comission > 0 {
                Label {
                    Text("Commission: \(sale.comission, specifier: "%.2f") €")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "percent")
                        .foregroundColor(.secondary)
                }
            }
            
            if let paymentMethod = sale.payment_method, !paymentMethod.isEmpty {
                Label {
                    Text("Paiement: \(formattedPaymentMethod(paymentMethod))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "creditcard")
                        .foregroundColor(.secondary)
                }
            }
            
            if let session = session {
                Label {
                    Text("Session: \(session.name)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                }
            } else if let sessionId = sale.id_session {
                Label {
                    Text("Session: #\(sessionId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var gamesSoldView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .padding(.vertical, 10)
            
            HStack {
                Text("Jeux vendus:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if isLoadingDetails {
                    ProgressView()
                        .scaleEffect(0.7)
                        .padding(.leading, 4)
                }
            }
            .padding(.bottom, 8)
            
            // Show either detailed or basic game information
            if let detailedSale = detailedSale {
                ForEach(detailedSale.games_sold, id: \.id_game) { gameDetail in
                    DetailedGameInfoView(
                        gameSold: gameDetail,
                        game: gameLookup[gameDetail.id_game]
                    )
                    .padding(.bottom, 8)
                }
            } else {
                ForEach(sale.games_sold, id: \.id_game) { gameSold in
                    SaleGameInfoView(
                        gameSold: gameSold,
                        game: gameLookup[gameSold.id_game]
                    )
                    .padding(.bottom, 8)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color.gray.opacity(0.03))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func formattedPaymentMethod(_ method: String) -> String {
        switch method.lowercased() {
        case "credit_card", "card": return "Carte"
        case "cash": return "Espèces"
        case "check", "transfer": return "Autres"
        default: return method
        }
    }
    
    /// Look up related data on the main thread to avoid actor isolation issues
    private func lookupRelatedData() {
        // Find seller
        seller = sellerViewModel.sellers.first(where: { $0.id_seller == sale.id_seller })
        
        // Find client
        client = clientViewModel.clients.first(where: { $0.id_client == sale.id_client })
        
        // Find session - fixed conditional binding
        if let sessionId = sale.id_session {
            session = sessionViewModel.sessions.first(where: { $0.id_session == sessionId })
        } else {
            session = nil // Clear session if id_session is nil
        }
        
        // Create game lookup dictionary
        var lookup: [Int: Game] = [:]
        for gameSold in sale.games_sold {
            if let game = gameViewModel.games.first(where: { $0.id_game == gameSold.id_game }) {
                lookup[gameSold.id_game] = game
            }
        }
        gameLookup = lookup
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func fetchSaleDetails() async {
        guard !isLoadingDetails, detailedSale == nil, let saleId = sale.id_sale, !saleId.isEmpty else { return }
        
        isLoadingDetails = true
        
        do {
            if let saleData = try await fetchData(from: "sales/\(saleId)", reqMethod: "GET", token: authToken) {
                let decoder = JSONDecoder()
                
                // Try a more flexible date decoding strategy
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                // Use a custom date decoding strategy that falls back to alternatives
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try the primary format first
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                    
                    // Fall back to other common formats
                    let fallbackFormatters = [
                        "yyyy-MM-dd'T'HH:mm:ssZ",
                        "yyyy-MM-dd'T'HH:mm:ss",
                        "yyyy-MM-dd"
                    ]
                    
                    for format in fallbackFormatters {
                        dateFormatter.dateFormat = format
                        if let date = dateFormatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Cannot decode date: \(dateString)"
                    )
                }
                
                do {
                    let result = try decoder.decode(DetailedSale.self, from: saleData)
                    
                    // Debug print to check if tags are present
                    print("Detailed sale decoded: \(result.id_sale)")
                    for game in result.games_sold {
                        print("Game \(game.id_game) tags: \(game.tags)")
                    }
                    
                    DispatchQueue.main.async {
                        self.detailedSale = result
                        self.isLoadingDetails = false
                        
                        // Update game lookup for detailed games
                        self.updateGameLookupForDetailedGames()
                    }
                } catch {
                    print("Error decoding detailed sale: \(error)")
                    DispatchQueue.main.async {
                        self.isLoadingDetails = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingDetails = false
                }
            }
        } catch {
            print("Error fetching sale details: \(error)")
            DispatchQueue.main.async {
                self.isLoadingDetails = false
            }
        }
    }
    
    private func updateGameLookupForDetailedGames() {
        guard let detailedSale = detailedSale else { return }
        
        // Create updated game lookup dictionary
        var updatedLookup = gameLookup
        
        for gameSold in detailedSale.games_sold {
            if let game = gameViewModel.games.first(where: { $0.id_game == gameSold.id_game }) {
                updatedLookup[gameSold.id_game] = game
            }
        }
        
        gameLookup = updatedLookup
    }
}

// MARK: - People Information Components

struct ClientInfoView: View {
    let client: Client?
    
    var body: some View {
        Label {
            Text(client != nil 
                 ? "Client: \(client!.firstname) \(client!.lastname)"
                 : "Client inconnu")
                .font(.subheadline)
                .foregroundColor(client != nil ? .primary : .secondary)
        } icon: {
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(client != nil ? .secondary : .gray)
        }
    }
}

struct SellerInfoView: View {
    let seller: Seller?
    
    var body: some View {
        Label {
            Text(seller != nil 
                 ? "Vendeur: \(seller!.firstname) \(seller!.lastname)"
                 : "Vendeur inconnu")
                .font(.subheadline)
                .foregroundColor(seller != nil ? .primary : .secondary)
        } icon: {
            Image(systemName: "person.fill")
                .foregroundColor(seller != nil ? .secondary : .gray)
        }
    }
}

// MARK: - Game Components

struct SaleGameInfoView: View {
    let gameSold: GameSold
    let game: Game?
    
    var body: some View {
        gameCardView {
            // Basic game info
            if let game = game {
                Text(game.name)
                    .font(.subheadline)
            } else {
                Text("Jeu inconnu (ID: \(gameSold.id_game))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Tags if available
            if let tags = gameSold.tags, !tags.isEmpty {
                TagsScrollView(tags: tags)
            }
        }
    }
}

struct DetailedGameInfoView: View {
    let gameSold: DetailedGameSold
    let game: Game?
    
    var body: some View {
        gameCardView {
            // Basic game info
            if let game = game {
                Text(game.name)
                    .font(.subheadline)
            } else {
                Text("Jeu inconnu (ID: \(gameSold.id_game))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // ALWAYS add the TagsScrollView
            TagsScrollView(tags: gameSold.tags)
                .frame(minHeight: 30) // Force minimum height to ensure visibility
        }
    }
}

// MARK: - Shared Components

struct TagsScrollView: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !tags.isEmpty {
                Text("Tags:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            // Display the full tag without truncation
                            Text(tag)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.bottom, 2)
                }
                .frame(minHeight: 34)
            } else {
                Text("No tags available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.top, 4)
    }
}

// Helper function for game card layout
extension View {
    func gameCardView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        HStack {
            Label {
                VStack(alignment: .leading) {
                    content()
                }
            } icon: {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quantity badge
            if let gameSold = self as? SaleGameInfoView, gameSold.gameSold.quantity > 0 {
                Text("Qté: \(gameSold.gameSold.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            } else if let gameSold = self as? DetailedGameInfoView, gameSold.gameSold.quantity > 0 {
                Text("Qté: \(gameSold.gameSold.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(6)
    }
}

// MARK: - Models

struct DetailedSale: Codable, Identifiable {
    var id: String { id_sale }
    var id_sale: String
    var date: Date?
    var amount: Double
    var comission: Double
    var payment_method: String?
    var id_seller: String
    var id_client: Int
    var id_manager: String?
    var id_session: Int?
    var games_sold: [DetailedGameSold]
    
    enum CodingKeys: String, CodingKey {
        case id_sale, date, amount, comission, payment_method, id_seller, id_client, id_manager, id_session, games_sold
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id_sale = try container.decode(String.self, forKey: .id_sale)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        id_seller = try container.decode(String.self, forKey: .id_seller)
        id_client = try container.decode(Int.self, forKey: .id_client)
        id_manager = try container.decodeIfPresent(String.self, forKey: .id_manager)
        id_session = try container.decodeIfPresent(Int.self, forKey: .id_session)
        payment_method = try container.decodeIfPresent(String.self, forKey: .payment_method)
        
        // Handle string to Double conversion
        if let amountString = try? container.decode(String.self, forKey: .amount) {
            amount = Double(amountString) ?? 0.0
        } else {
            amount = try container.decode(Double.self, forKey: .amount)
        }
        
        if let comissionString = try? container.decode(String.self, forKey: .comission) {
            comission = Double(comissionString) ?? 0.0
        } else {
            comission = try container.decode(Double.self, forKey: .comission)
        }
        
        games_sold = try container.decode([DetailedGameSold].self, forKey: .games_sold)
    }
}

struct DetailedGameSold: Codable, Identifiable {
    var id: Int { id_game }
    var id_game: Int
    var quantity: Int
    var tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case id_game, quantity, tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id_game = try container.decode(Int.self, forKey: .id_game)
        quantity = try container.decode(Int.self, forKey: .quantity)
        
        // More robust tag handling
        do {
            tags = try container.decode([String].self, forKey: .tags)
        } catch {
            print("Error decoding tags: \(error). Setting empty array.")
            tags = []
        }
    }
}