//
//  GameCategoriesListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct GameCategoriesListView: View {
    @StateObject var viewModel = GameCategoryViewModel()
    @State private var showDeleteAlert = false
    @State private var categoryToDelete: Int?
    
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
                        .onDelete(perform: confirmDelete)
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
            .alert("Supprimer la catégorie", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let categoryID = categoryToDelete {
                        Task {
                            await viewModel.deleteGameCategory(categoryID: categoryID)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cette catégorie ? Cette action est irréversible.")
            }
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            categoryToDelete = viewModel.gameCategories[index].id_category
            showDeleteAlert = true
        }
    }
}