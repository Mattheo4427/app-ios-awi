//
//  RegisterView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct RegisterView: View {
    // State variables to hold text input from the user
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPasswordSecure = true
    @State private var showConfirmPasswordSecure = true
    @State private var showErrorMessage = false
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                // Email TextField
                TextField("Email", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                // Password TextField
                HStack {
                    if showPasswordSecure {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                            .padding(.horizontal)
                    } else {
                        TextField("Password", text: $password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                            .padding(.horizontal)
                    }

                    Button(action: {
                        showPasswordSecure.toggle()
                    }) {
                        Image(systemName: showPasswordSecure ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 12)
                }

                // Confirm Password TextField
                HStack {
                    if showConfirmPasswordSecure {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                            .padding(.horizontal)
                    } else {
                        TextField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                            .padding(.horizontal)
                    }

                    Button(action: {
                        showConfirmPasswordSecure.toggle()
                    }) {
                        Image(systemName: showConfirmPasswordSecure ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 12)
                }

                // Error message (if any)
                if showErrorMessage {
                    Text("Passwords do not match.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                // Register Button
                Button(action: {
                    if validateRegistration() {
                        print("Registration successful")
                    } else {
                        showErrorMessage = true
                    }
                }) {
                    Text("Register")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            
            // Login Link
            NavigationLink(destination: LoginView()) {
                Text("Already have an account? Login")
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding()
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .padding()
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.endEditing()
        }
    }

    // Simple validation for registration
    private func validateRegistration() -> Bool {
        // Check if the email is valid and passwords match
        if email.isEmpty || password.isEmpty || !email.contains("@") || password != confirmPassword {
            return false
        }
        return true
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
