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
            VStack(alignment: .leading) {
                Text("Nom de l'éditeur")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Nom", text: $name)
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $descriptionText)
                    .frame(minHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.vertical, 4)
            }
            
            Section {
                Button("Créer Editeur") {
                    Task {
                        let newEditor = GameEditor(
                            id_editor: Int.random(in: 1000...9999), // Temporary ID
                            name: name,
                            description: descriptionText.isEmpty ? nil : descriptionText
                        )
                        await viewModel.createGameEditor(editor: newEditor)
                        if viewModel.errorMessage == nil {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle("Nouvel Editeur")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}