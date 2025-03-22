//
//  app_ios_awiApp.swift
//  app-ios-awi
//
//  Created by etud on 12/03/2025.
//

import SwiftUI

@main
struct app_ios_awiApp: App {
    init() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "authToken")
        print("🧹 authToken supprimé au démarrage")
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }
}
