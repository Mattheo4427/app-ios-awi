//
//  ProfileView.swift
//  app-ios-awi
//
//  Created by etud on 19/03/2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Mon Profil")
                .font(.title)
                .fontWeight(.medium)
            
            Text("Informations de profil et paramètres du compte")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
