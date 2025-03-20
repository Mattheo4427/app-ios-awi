//
//  GameCategoriesListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct GameCategoriesListView: View {
    @StateObject var viewModel = GameCategoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.gameCategories.isEmpty {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucune catégorie trouvée")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucune catégorie de jeux enregistrée.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.gameCategories, id: \.id_category) { category in
                            NavigationLink(destination: UpdateGameCategoryView(viewModel: viewModel, category: category)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                    Text(category.description ?? "Aucune description")
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: deleteCategory)
                    }
                }
            }
            .navigationTitle("Catégories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateGameCategoryView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.fetchGameCategories()
            }
        }
    }
    
    func deleteCategory(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let categoryID = viewModel.gameCategories[index].id_category
                await viewModel.deleteGameCategory(categoryID: categoryID)
            }
        }
    }
}