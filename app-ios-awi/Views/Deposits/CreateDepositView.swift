import SwiftUI

struct CreateDepositView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: DepositViewModel
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var sellerViewModel = SellerViewModel()

    @State private var selectedSeller: Seller?
    @State private var selectedGame: Game?
    @State private var quantity = ""
    @State private var sellingPrice = "" // Price the seller wants to sell each game for
    @State private var openedSession: Session?

    // Basic conversions
    var computedQuantity: Double {
        Double(quantity) ?? 0
    }
    
    var computedSellingPrice: Double {
        Double(sellingPrice) ?? 0
    }
    
    // Single commission fee per deposit from session
    var commissionFee: Double {
        if let session = openedSession, let fee = Double(session.deposit_fees) {
            return fee
        }
        return 0
    }
    
    // Discount = session.discount (%) applied on commission
    var computedDiscountFinal: Double {
        if let session = openedSession, let disc = Double(session.discount) {
            return disc / 100 * commissionFee
        }
        return 0
    }
    
    // Final amount the seller pays: commission - discount
    var computedFinalCommission: Double {
        commissionFee - computedDiscountFinal
    }
    
    // Display helpers with units
    var displayCommissionFee: String {
        String(format: "%.2f €", commissionFee)
    }
    
    var displayDiscount: String {
        if let session = openedSession {
            return String(format: "%.2f%% (%.2f €)", Double(session.discount) ?? 0, computedDiscountFinal)
        }
        return "0.00% (0.00 €)"
    }
    
    var displayFinalCommission: String {
        String(format: "%.2f €", computedFinalCommission)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Informations")) {
                // Seller picker
                VStack(alignment: .leading) {
                    Text("Vendeur")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if sellerViewModel.sellers.isEmpty {
                        Text("Chargement des vendeurs...")
                            .foregroundColor(.gray)
                    } else {
                        Menu {
                            ForEach(sellerViewModel.sellers) { seller in
                                Button(seller.username) {
                                    selectedSeller = seller
                                }
                            }
                        } label: {
                            Text(selectedSeller?.username ?? "Sélectionner un vendeur")
                                .foregroundColor(selectedSeller == nil ? .gray : .primary)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                // Game picker
                VStack(alignment: .leading) {
                    Text("Jeu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if gameViewModel.games.isEmpty {
                        Text("Chargement des jeux...")
                            .foregroundColor(.gray)
                    } else {
                        Menu {
                            ForEach(gameViewModel.games) { game in
                                Button(game.name) {
                                    selectedGame = game
                                }
                            }
                        } label: {
                            Text(selectedGame?.name ?? "Sélectionner un jeu")
                                .foregroundColor(selectedGame == nil ? .gray : .primary)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                // Quantity field
                VStack(alignment: .leading) {
                    Text("Quantité")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Quantité", text: $quantity)
                        .keyboardType(.numberPad)
                }
                .padding(.vertical, 4)
                
                // Selling price field (price buyer will pay)
                VStack(alignment: .leading) {
                    Text("Prix de vente unitaire")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Prix de vente (€)", text: $sellingPrice)
                        .keyboardType(.decimalPad)
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Frais de commission")) {
                // Commission fee display (not editable)
                VStack(alignment: .leading) {
                    Text("Frais de commission")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(displayCommissionFee)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 4)
                
                // Commission fee calculation summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Commission: \(displayCommissionFee)")
                    Text("Remise: \(displayDiscount)")
                    Divider()
                    Text("Montant à payer: \(displayFinalCommission)")
                        .fontWeight(.bold)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Button("Créer Dépôt") {
                    Task {
                        guard let seller = selectedSeller, 
                              let game = selectedGame,
                              !quantity.isEmpty,
                              !sellingPrice.isEmpty else { return }
                        
                        do {
                            if openedSession == nil {
                                if let sessionData = try await fetchData(from: "sessions/opened", reqMethod: "GET", token: nil),
                                   let session: Session = decodeJSON(from: sessionData, as: Session.self) {
                                    openedSession = session
                                }
                            }
                            
                            if let session = openedSession {
                                let newDeposit = CreateDepositDto(
                                    date: Date(),
                                    amount: computedFinalCommission,
                                    fees: commissionFee,
                                    discount: computedDiscountFinal,
                                    id_seller: seller.id_seller,
                                    id_session: session.id_session,
                                    games_deposited: [
                                        GameDepositedDto(
                                            id_game: game.id_game,
                                            quantity: Int(quantity) ?? 0,
                                            price: computedSellingPrice, // This is the price for buyers
                                            nb_for_sale: 0
                                        )
                                    ]
                                )
                                
                                await viewModel.createDeposit(deposit: newDeposit)
                                presentationMode.wrappedValue.dismiss()
                            }
                        } catch {
                            print("Error fetching open session: \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(selectedSeller == nil || selectedGame == nil || quantity.isEmpty || sellingPrice.isEmpty)
            }
        }
        .navigationTitle("Nouveau Dépôt")
        .alert(isPresented: Binding<Bool>(
            get: {
                viewModel.errorMessage != nil ||
                gameViewModel.errorMessage != nil ||
                sellerViewModel.errorMessage != nil
            },
            set: { newValue in
                if !newValue {
                    viewModel.dismissError()
                    gameViewModel.dismissError()
                    sellerViewModel.dismissError()
                }
            }
        )) {
            Alert(
                title: Text("Erreur"),
                message: Text(viewModel.errorMessage ?? gameViewModel.errorMessage ?? sellerViewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            Task {
                await gameViewModel.fetchGames()
                await sellerViewModel.fetchSellers()
                if let sessionData = try? await fetchData(from: "sessions/opened", reqMethod: "GET", token: nil),
                   let session: Session = decodeJSON(from: sessionData, as: Session.self) {
                    openedSession = session
                }
            }
        }
    }
}