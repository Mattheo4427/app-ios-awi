//
//  HomeView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
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
                } else if viewModel.categories.isEmpty && viewModel.games.isEmpty {
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Catalogue vide")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Aucun jeu ou catégorie n'est disponible pour le moment.")
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
                        if !viewModel.categories.isEmpty {
                            Section(header: Text("Catégories")) {
                                ForEach(viewModel.categories, id: \.id) { category in
                                    Text(category.name)
                                }
                            }
                        }
                        
                        if !viewModel.games.isEmpty {
                            Section(header: Text("Jeux")) {
                                ForEach(viewModel.games, id: \.id) { game in
                                    Text(game.tag) // Adjusted to use the correct property
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Catalogue", displayMode: .inline)
            .onAppear {
                Task {
                    await viewModel.fetchCatalogue()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
