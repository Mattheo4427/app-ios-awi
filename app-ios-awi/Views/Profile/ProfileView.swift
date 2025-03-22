import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel();

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Chargement du profil...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.blue)
                                .padding(.top, 20)
                            
                            if let manager = viewModel.managerProfile {
                                ProfileDetailsView(
                                    viewModel: viewModel,
                                    username: manager.username,
                                    firstname: manager.firstname,
                                    lastname: manager.lastname,
                                    email: manager.email,
                                    phone: manager.phone,
                                    address: manager.address,
                                    createdAt: manager.createdAt,
                                    isAdmin: manager.is_admin ? "Administrateur" : nil
                                )
                            } else if let seller = viewModel.sellerProfile {
                                ProfileDetailsView(
                                    viewModel: viewModel,
                                    username: seller.username ?? "Non spécifié",
                                    firstname: seller.firstname,
                                    lastname: seller.lastname,
                                    email: seller.email,
                                    phone: seller.phone ?? "Non spécifié",
                                    address: seller.address,
                                    createdAt: seller.createdAt,
                                    isAdmin: "Vendeur"
                                )
                            } else {
                                Text("Aucune information de profil disponible.")
                                    .font(.title2)
                                    .padding()
                            }

                            Divider()

                            VStack(spacing: 10) {
                                Button(action: {
                                    Task {
                                        await viewModel.fetchProfile()
                                    }
                                }) {
                                    Text("Actualiser le profil")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }

                                Button(action: {
                                    viewModel.logout()
                                }) {
                                    Text("Se déconnecter")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Profil", displayMode: .inline)
            .onAppear {
                viewModel.checkAuthState()
                Task {
                    await viewModel.fetchProfile()
                }
                viewModel.printAppStorageValues()
            }
        }
    }
}

struct ProfileDetailsView: View {
    let viewModel: ProfileViewModel
    let username: String
    let firstname: String
    let lastname: String
    let email: String
    let phone: String
    let address: String?
    let createdAt: String
    let isAdmin: String?

    var body: some View {
        VStack(spacing: 10) {
            Text("\(firstname) \(lastname)")
                .font(.title)
                .fontWeight(.bold)

            Text(email)
                .font(.body)
                .foregroundColor(.secondary)

            if let isAdmin = isAdmin {
                Text(isAdmin)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                ProfileRow(label: "Nom d'utilisateur", value: username)
                ProfileRow(label: "Téléphone", value: phone)
                if let address = address {
                    ProfileRow(label: "Adresse", value: address)
                }
                ProfileRow(label: "Compte créé le", value: viewModel.formatDate(createdAt))
            }
            .padding(.horizontal)
        }
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()
            Text("Erreur")
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}


/// Composant réutilisable pour afficher une ligne d'information du profil
struct ProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
