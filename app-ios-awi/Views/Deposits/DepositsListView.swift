import SwiftUI

struct DepositsListView: View {
    @StateObject var viewModel = DepositViewModel()
    @State private var showDeleteAlert = false
    @State private var depositToDelete: String?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.deposits.isEmpty {
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
                } else {
                    List {
                        ForEach(viewModel.deposits) { deposit in
                            // Regular view instead of NavigationLink
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dépôt #\(deposit.id_deposit)")
                                    .font(.headline)
                                Text("Date: \(formattedDate(deposit.date))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Montant: \(deposit.amount, specifier: "%.2f") €")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: confirmDelete)
                    }
                }
            }
            .navigationTitle("Dépôts")
            .toolbar {
                NavigationLink(destination: CreateDepositView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchDeposits()
            }
            .refreshable {
                await viewModel.fetchDeposits()
            }
            .alert("Erreur", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.dismissError() }}
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Supprimer le dépôt", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let depositID = depositToDelete {
                        Task { await viewModel.deleteDeposit(depositID: depositID) }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer ce dépôt ? Cette action est irréversible.")
            }
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            depositToDelete = viewModel.deposits[index].id_deposit
            showDeleteAlert = true
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
