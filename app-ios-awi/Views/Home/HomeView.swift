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
            VStack {
                if viewModel.isLoading {
                    ProgressView("Chargement du catalogue...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Erreur : \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List {
                        Section(header: Text("Catégories")) {
                            ForEach(viewModel.categories, id: \._id) { category in
                                Text(category.name)
                            }
                        }
                        
                        Section(header: Text("Jeux")) {
                            ForEach(viewModel.games, id: \._id) { game in
                                Text(game.name)
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

// MARK: - Models
struct Game: Codable {
    let _id: String
    let name: String
}

struct GameCategory: Codable {
    let _id: String
    let name: String
}

