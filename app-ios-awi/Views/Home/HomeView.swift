//
//  HomeView.swift
//  app-ios-awi
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
                } else if viewModel.mergedGames.isEmpty {
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("Catalogue vide")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Aucun jeu n'est disponible pour le moment.")
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
                        ForEach(viewModel.mergedGames) { mergedGame in
                            VStack(alignment: .leading) {
                                if let gameDetails = mergedGame.gameDetails {
                                    HStack(alignment: .top, spacing: 12) {
                                        // Game image
                                        AsyncImage(url: URL(string: gameDetails.image ?? "")) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 80, height: 80)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                                    .frame(width: 80, height: 80)
                                            @unknown default:
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                                    .frame(width: 80, height: 80)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(gameDetails.name)
                                                .font(.headline)
                                            
                                            HStack {
                                                Text("👥 \(gameDetails.min_players)-\(gameDetails.max_players)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                Text("📅 \(gameDetails.min_age)-\(gameDetails.max_age) ans")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            if let description = gameDetails.description {
                                                Text(description)
                                                    .lineLimit(2)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer().frame(height: 8)
                                            
                                            HStack {
                                                Text("💰 \(mergedGame.price)€")
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                
                                                Spacer()
                                                
                                                Text("📦 \(mergedGame.count) disponible\(mergedGame.count > 1 ? "s" : "")")
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                } else {
                                    // Simple view for when game details haven't loaded yet
                                    HStack {
                                        Text("Jeu #\(mergedGame.gameId)")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(mergedGame.price)€ × \(mergedGame.count)")
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
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
            .refreshable {
                await viewModel.fetchCatalogue()
            }
        }
    }
}