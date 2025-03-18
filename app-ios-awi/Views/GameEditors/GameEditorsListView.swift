//
//  GameEditorsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct GameEditorsListView: View {
    @StateObject var viewModel = GameEditorViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.gameEditors.isEmpty {
                    VStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("Aucun éditeur trouvé")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Il n'y a actuellement aucun éditeur de jeux enregistré.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    List {
                        ForEach(viewModel.gameEditors) { editor in
                            NavigationLink(destination: UpdateGameEditorView(viewModel: viewModel, editor: editor)) {
                                Text(editor.name)
                                    .font(.headline)
                            }
                        }
                        .onDelete(perform: deleteEditor)
                    }
                }
            }
            .navigationTitle("Editeurs")
            .toolbar {
                NavigationLink(destination: CreateGameEditorView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchGameEditors()
            }
        }
    }
    
    func deleteEditor(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let editorID = viewModel.gameEditors[index].id_editor
                await viewModel.deleteGameEditor(editorID: editorID)
            }
        }
    }
}