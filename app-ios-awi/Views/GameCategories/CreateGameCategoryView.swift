//
//  CreateGameCategoryView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateGameCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameCategoryViewModel
    
    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        Form {
            TextField("Nom", text: $name)
            TextField("Description", text: $descriptionText)
            
            Button("Créer Catégorie") {
                Task {
                    let newCategory = GameCategory(
                        id_category: Int.random(in: 1000...9999), // Temporary ID
                        name: name,
                        description: descriptionText.isEmpty ? nil : descriptionText
                    )
                    await viewModel.createGameCategory(category: newCategory)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouvelle Catégorie")
    }
}