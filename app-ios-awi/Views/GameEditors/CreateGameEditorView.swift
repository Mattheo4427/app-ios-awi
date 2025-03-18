//
//  CreateGameEditorView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct CreateGameEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameEditorViewModel
    
    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        Form {
            TextField("Nom", text: $name)
            TextField("Description", text: $descriptionText)
            
            Button("Créer Editeur") {
                Task {
                    let newEditor = GameEditor(
                        id_editor: Int.random(in: 1000...9999), // Temporary ID
                        name: name,
                        description: descriptionText.isEmpty ? nil : descriptionText
                    )
                    await viewModel.createGameEditor(editor: newEditor)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Nouvel Editeur")
    }
}