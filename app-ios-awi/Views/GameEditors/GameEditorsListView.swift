//
//  GameEditorsListView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//
import SwiftUI

struct GameEditorsListView: View {
    @StateObject var viewModel = GameEditorViewModel()
    @State private var showDeleteAlert = false
    @State private var editorToDelete: Int?
    
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
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(editor.name)
                                        .font(.headline)
                                    Text(editor.description ?? "Aucune description")
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
            .navigationTitle("Editeurs")
            .toolbar {
                NavigationLink(destination: CreateGameEditorView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            .task {
                await viewModel.fetchGameEditors()
            }
            .alert("Supprimer l'éditeur", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    if let editorID = editorToDelete {
                        Task {
                            await viewModel.deleteGameEditor(editorID: editorID)
                        }
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir supprimer cet éditeur ? Cette action est irréversible.")
            }
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            editorToDelete = viewModel.gameEditors[index].id_editor
            showDeleteAlert = true
        }
    }
}