//
//  BalanceView.swift
//  app-ios-awi
//
//  Created by etud on 18/03/2025.
//

import SwiftUI

struct BalanceView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "chart.bar")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                Text("Bilan")
                    .font(.largeTitle)
                    .padding(.top, 16)
                Text("Les infos du bilan apparaîtront ici.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .navigationTitle("Bilan")
        }
    }
}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView()
    }
}
