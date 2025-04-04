//
//  LoginView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()  // Initialize ViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Connexion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    HStack {
                        ZStack(alignment: .trailing) {
                            if viewModel.isPasswordSecure {
                                SecureField("Mot de passe", text: $viewModel.password)
                                    .padding(.trailing, 40) // Give space for the eye icon
                            } else {
                                TextField("Mot de passe", text: $viewModel.password)
                                    .padding(.trailing, 40) // Give space for the eye icon
                            }
                            
                            Button(action: {
                                viewModel.isPasswordSecure.toggle()
                            }) {
                                Image(systemName: viewModel.isPasswordSecure ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        
                    }

                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                      if viewModel.isLoading {
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else {
                            Text("Connexion")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .fullScreenCover(isPresented: $viewModel.loginSuccess) {
                HomeView()
            }
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
}


// Helper to dismiss the keyboard
extension UIApplication {
    func endEditing() {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.endEditing(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}