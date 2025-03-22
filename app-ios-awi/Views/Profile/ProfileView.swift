import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Chargement du profil...")
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
                } else if viewModel.isAuthenticated, let managerProfile = viewModel.managerProfile {
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.blue)
                                .padding(.top, 20)
                            
                            Text("\(managerProfile.firstname) \(managerProfile.lastname)")
                                .font(.title)
                                .fontWeight(.bold)

                            Text(managerProfile.email)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if viewModel.isAdmin {
                                Text("Administrateur")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 10) {
                                Section {
                                    ProfileRow(label: "Nom d'utilisateur", value: managerProfile.username)
                                    ProfileRow(label: "Téléphone", value: managerProfile.phone)
                                    if let address = managerProfile.address {
                                        ProfileRow(label: "Adresse", value: address)
                                    }
                                    ProfileRow(label: "Compte créé le", value: formatDate(managerProfile.createdAt))
                                }
                            }
                            .padding(.horizontal)

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
                } else {
                    VStack {
                        Text("Vous n'êtes pas connecté.")
                            .font(.title2)
                            .padding()

                        Button("Se connecter") {
                            viewModel.navigateToLogin = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationBarTitle("Profil", displayMode: .inline)
            .onAppear {
                Task {
                    await viewModel.fetchProfile()
                }
                viewModel.printAppStorageValues()
            }
        }
    }

    /// Formate la date pour l'affichage
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return "Date inconnue"
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
