//
//  UpdateGameCategoryView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateGameCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameCategoryViewModel
    @State var category: GameCategory

    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        Form {
            TextField("Nom", text: $name)
            TextField("Description", text: $descriptionText)
            
            Button("Modifier Catégorie") {
                Task {
                    let updatedCategory = GameCategory(
                        id_category: category.id_category,
                        name: name,
                        description: descriptionText.isEmpty ? nil : descriptionText
                    )
                    await viewModel.updateGameCategory(category: updatedCategory)
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Modification Catégorie")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .onAppear {
            name = category.name
            descriptionText = category.description ?? ""
        }
    }
}
