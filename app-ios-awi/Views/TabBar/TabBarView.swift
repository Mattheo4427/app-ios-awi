//
//  TabBarView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var selectedSubTab: String? = nil
    @State private var expandedMenu: TabItem? = nil
    
    // Define all tab items
    private let tabItems = [
        ("Catalogue", "house"),
        ("Utilisateurs", "person.3.fill"),
        ("Jeux", "gamecontroller.fill"),
        ("Transactions", "creditcard.fill"),
        ("Sessions", "calendar.badge.exclamationmark"),
        ("Connexion", "person.circle")
    ]
    
    // Define expandable menus
    private let expandableMenus: [String: [TabItem.MenuItem]] = [
        "Utilisateurs": [
            TabItem.MenuItem(icon: "person.fill", title: "Clients"),
            TabItem.MenuItem(icon: "cart.fill", title: "Vendeurs"),
            TabItem.MenuItem(icon: "briefcase.fill", title: "Managers")
        ],
        "Jeux": [
            TabItem.MenuItem(icon: "gamecontroller", title: "Jeux"),
            TabItem.MenuItem(icon: "person.2.fill", title: "Editeurs"),
            TabItem.MenuItem(icon: "list.bullet", title: "Catégories")
        ],
        "Transactions": [
            TabItem.MenuItem(icon: "dollarsign.circle", title: "Dépôts"),
            TabItem.MenuItem(icon: "bag.fill", title: "Ventes"),
            TabItem.MenuItem(icon: "arrow.down.circle", title: "Retraits"),
            TabItem.MenuItem(icon: "chart.bar", title: "Bilan")
        ]
    ]
    
    var body: some View {
        ZStack {
            // Content area (your main views)
            VStack(spacing: 0) {
                // Main content
                ZStack {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        if selectedSubTab == "Clients" {
                            ClientsListView()
                        } else if selectedSubTab == "Managers" {
                            ManagersListView()
                        } else if selectedSubTab == "Vendeurs" {
                            SellersListView()
                        } else {
                            PlaceholderView(title: "Utilisateurs", icon: "person.3.fill")
                        }
                    case 2:
                        if selectedSubTab == "Jeux" {
                            GamesListView()
                        } else if selectedSubTab == "Editeurs" {
                            GameEditorsListView()
                        } else if selectedSubTab == "Catégories" {
                            GameCategoriesListView()
                        } else {
                            PlaceholderView(title: "Jeux", icon: "gamecontroller.fill")
                        }
                    case 3:
                        if selectedSubTab == "Dépôts" {
                            DepositsListView()
                        } else if selectedSubTab == "Ventes" {
                            SalesListView()
                        } else if selectedSubTab == "Retraits" {
                            WithdrawalsListView()
                        } else if selectedSubTab == "Bilan" {
                            BalanceView()
                        }
                        else {
                            PlaceholderView(title: "Transactions", icon: "creditcard.fill")
                        }
                    case 4:
                        SessionsListView()
                    case 5:
                        LoginView()
                    default:
                        HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar - Now positioned directly at the bottom with no extra space
                customTabBar
            }
            .zIndex(0) // Force main content to be on base layer
            
            // Expandable Menu Overlay - place this AFTER content to ensure it's on top
            if let menu = expandedMenu {
                // Dimmed background overlay
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            expandedMenu = nil
                        }
                    }
                    .zIndex(1) // Layer 1: Background overlay
                
                // Menu items in separate layer with higher z-index
                VStack {
                    Spacer()
                    // Menu items
                    VStack(spacing: 12) {
                        ForEach(menu.items, id: \.title) { item in
                            ExpandableTabButton(icon: item.icon, text: item.title) {
                                selectedSubTab = item.title  // Set the selected sub tab
                                print("\(item.title) tapped")
                                withAnimation(.spring()) {
                                    expandedMenu = nil
                                }
                            }
                        }
                    }
                    // Adjusted bottom padding to position menu closer to tab bar
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom))
                }
                .zIndex(2) // Layer 2: Menu buttons (highest)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Custom Tab Bar View
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabItems.count, id: \.self) { index in
                let item = tabItems[index]
                let isExpendable = isExpandableTab(item.0)
                
                Button {
                    if isExpendable {
                        toggleMenu(name: item.0)
                    } else {
                        withAnimation {
                            selectedTab = index
                            selectedSubTab = nil
                            expandedMenu = nil
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            // Show different icon if menu is expanded for this tab
                            if isExpendable && expandedMenu?.name == item.0 {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: item.1)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text(item.0)
                            .font(.system(size: 10))
                            .padding(.bottom, 30)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(UIColor.systemGray4)),
            alignment: .top
        )
    }
    
    // Check if a tab is expandable
    private func isExpandableTab(_ name: String) -> Bool {
        return expandableMenus.keys.contains(name)
    }
    
    private func toggleMenu(name: String) {
        withAnimation(.spring()) {
            if expandedMenu?.name == name {
                expandedMenu = nil  // Close if already open
            } else {
                if let items = expandableMenus[name] {
                    expandedMenu = TabItem(name: name, items: items)
                    selectedTab = tabItems.firstIndex(where: { $0.0 == name }) ?? selectedTab
                }
            }
        }
    }
}

// Expandable Menu Item Button
struct ExpandableTabButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(10)
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.trailing, 10)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(Color.blue)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        }
    }
}

// Placeholder View
struct PlaceholderView: View {
    var title: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title)
                .fontWeight(.medium)
            
            Text("Sélectionnez une option du menu")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// Struct for Expandable Menu Items
struct TabItem {
    let name: String
    let items: [MenuItem]
    
    struct MenuItem {
        let icon: String
        let title: String
    }
}

// Preview
struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
