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
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .padding()
                        
                        Text(managerProfile.username)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(managerProfile.email)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if viewModel.isAdmin {
                            Text("Administrateur")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchProfile()
                            }
                        }) {
                            Text("Actualiser le profil")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Text("Se déconnecter")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
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
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
