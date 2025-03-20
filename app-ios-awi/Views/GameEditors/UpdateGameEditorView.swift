//
//  UpdateGameEditorView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct UpdateGameEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameEditorViewModel
    @State var editor: GameEditor

    @State private var name = ""
    @State private var descriptionText = ""

    var body: some View {
        Form {
            TextField("Nom", text: $name)
            TextField("Description", text: $descriptionText)
            
            Button("Modifier Editeur") {
                Task {
                    let updatedEditor = GameEditor(
                        id_editor: editor.id_editor,
                        name: name,
                        description: descriptionText.isEmpty ? nil : descriptionText
                    )
                    await viewModel.updateGameEditor(editor: updatedEditor)
                    if viewModel.errorMessage == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationTitle("Modification Editeur")
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        ), actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .onAppear {
            name = editor.name
            descriptionText = editor.description ?? ""
        }
    }
}
