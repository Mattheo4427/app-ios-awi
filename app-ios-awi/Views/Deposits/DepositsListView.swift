import SwiftUI

// Main view
struct DepositsListView: View {
    @StateObject var viewModel = DepositViewModel()
    @StateObject var sellerViewModel = SellerViewModel()
    @StateObject var gameViewModel = GameViewModel()
    @State private var showDeleteAlert = false
    @State private var depositToDelete: String?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Chargement des données...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if viewModel.deposits.isEmpty {
                    EmptyStateView()
                } else {
                    depositListView
                }
            }
            .navigationTitle("Dépôts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateDepositView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await fetchData()
            }
            .refreshable {
                isLoading = true
                await fetchData()
            }
            .errorAlert(
                viewModel: viewModel,
                sellerViewModel: sellerViewModel,
                gameViewModel: gameViewModel
            )
            .deleteAlert(
                isPresented: $showDeleteAlert,
                itemToDelete: depositToDelete,
                deleteAction: { id in
                    Task { await viewModel.deleteDeposit(depositID: id) }
                }
            )
        }
    }

    private var depositListView: some View {
        List {
            ForEach(viewModel.deposits) { deposit in
                DepositRowView(
                    deposit: deposit,
                    sellerViewModel: sellerViewModel,
                    gameViewModel: gameViewModel
                )
            }
            .onDelete(perform: confirmDelete)
        }
    }
        
    // MARK: - Helper Methods
        
    private func fetchData() async {
        // Set loading state
        isLoading = true
        
        // 1. First, fetch deposits
        await viewModel.fetchDeposits()
        
        // 2. If we have deposits, fetch sellers and games
        if !viewModel.deposits.isEmpty {
            // Use Task groups to load sellers and games in parallel
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await sellerViewModel.fetchSellers() }
                group.addTask { await gameViewModel.fetchGames() }
                
                // Wait for all tasks to complete
                for await _ in group { }
            }
        }
        
        // After all data is loaded, set loading to false
        isLoading = false
    }

    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            depositToDelete = viewModel.deposits[index].id_deposit
            showDeleteAlert = true
        }
    }
}

// Empty state view
struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "tray.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            Text("Aucun dépôt trouvé")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Il n'y a actuellement aucun dépôt enregistré.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// Deposit row view
struct DepositRowView: View {
    let deposit: Deposit
    let sellerViewModel: SellerViewModel
    let gameViewModel: GameViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header section
            DepositHeaderView(deposit: deposit)
            
            // Seller information
            SellerInfoView(
                seller: sellerViewModel.sellers.first(where: { $0.id_seller == deposit.id_seller })
            )
            
            // Price details
            PriceDetailsView(fees: deposit.fees, discount: deposit.discount)
            
            // Game information
            if !deposit.games_deposited.isEmpty, let gameDeposit = deposit.games_deposited.first {
                GameInfoView(
                    gameDeposit: gameDeposit,
                    game: gameViewModel.games.first(where: { $0.id_game == gameDeposit.id_game })
                )
            }
        }
        .padding(.vertical, 6)
    }
}

// Header view for deposit
struct DepositHeaderView: View {
    let deposit: Deposit
    
    var body: some View {
        HStack {
            // Convert Substring to String
            Text("Dépôt #\(String(deposit.id_deposit.prefix(8)))")
                .font(.headline)
            Spacer()
            Text("\(deposit.amount, specifier: "%.2f") €")
                .font(.headline)
                .foregroundColor(.blue)
        }
        
        Text("Date: \(formattedDate(deposit.date))")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Price details view
struct PriceDetailsView: View {
    let fees: Double
    let discount: Double
    
    var body: some View {
        HStack(spacing: 12) {
            if fees > 0 {
                Text("Frais: \(fees, specifier: "%.2f") €")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if discount > 0 {
                Text("Remise: \(discount, specifier: "%.2f") €")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding(.top, 2)
    }
}

// Game information view
struct GameInfoView: View {
    let gameDeposit: GameDeposited
    let game: Game?
    
    var body: some View {
        Divider()
            .padding(.vertical, 4)
        
        HStack {
            if let game = game {
                Label {
                    Text("Jeu: \(game.name)")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.secondary)
                }
            } else {
                // More user-friendly fallback when game not found
                Label {
                    Text("Jeu inconnu")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Display quantity
            if gameDeposit.quantity > 0 {
                Text("Qté: \(gameDeposit.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - View Modifiers

// Error alert view modifier
struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var viewModel: DepositViewModel
    @ObservedObject var sellerViewModel: SellerViewModel
    @ObservedObject var gameViewModel: GameViewModel
    
    func body(content: Content) -> some View {
        content.alert("Erreur", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            } else if let error = sellerViewModel.errorMessage {
                Text(error)
            } else {
                Text(gameViewModel.errorMessage ?? "")
            }
        }
    }
    
    private var errorBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.errorMessage != nil ||
                   sellerViewModel.errorMessage != nil ||
                   gameViewModel.errorMessage != nil },
            set: { if !$0 {
                viewModel.dismissError()
                sellerViewModel.dismissError()
                gameViewModel.dismissError()
            }}
        )
    }
}

// Delete confirmation alert view modifier
struct DeleteAlertModifier<T>: ViewModifier {
    @Binding var isPresented: Bool
    let itemToDelete: T?
    let deleteAction: (T) -> Void
    
    func body(content: Content) -> some View {
        content.alert("Supprimer le dépôt", isPresented: $isPresented) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let item = itemToDelete {
                    deleteAction(item)
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer ce dépôt ? Cette action est irréversible.")
        }
    }
}

// MARK: - View Extensions

extension View {
    func errorAlert(viewModel: DepositViewModel, sellerViewModel: SellerViewModel, gameViewModel: GameViewModel) -> some View {
        self.modifier(ErrorAlertModifier(
            viewModel: viewModel,
            sellerViewModel: sellerViewModel,
            gameViewModel: gameViewModel
        ))
    }
    
    func deleteAlert<T>(isPresented: Binding<Bool>, itemToDelete: T?, deleteAction: @escaping (T) -> Void) -> some View {
        self.modifier(DeleteAlertModifier(
            isPresented: isPresented,
            itemToDelete: itemToDelete,
            deleteAction: deleteAction
        ))
    }
}
