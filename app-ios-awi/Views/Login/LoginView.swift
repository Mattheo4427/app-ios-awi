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
        NavigationView {  // Make sure you're inside a NavigationView for NavigationLink to work
            VStack {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                Spacer()

                VStack(alignment: .leading, spacing: 20) {
                    // Email TextField
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    // Password TextField
                    HStack {
                        if viewModel.isPasswordSecure {
                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                .padding(.horizontal)
                        } else {
                            TextField("Password", text: $viewModel.password)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                                .padding(.horizontal)
                        }

                        Button(action: {
                            viewModel.isPasswordSecure.toggle()
                        }) {
                            Image(systemName: viewModel.isPasswordSecure ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 12)
                    }

                    // Error message (if any)
                    if viewModel.showErrorMessage {
                        Text("Invalid email or password")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.horizontal)
                    }

                    // Login Button
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Login")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal)
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                UIApplication.shared.endEditing()
            }
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
