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
    
    @AppStorage("userRole") private var userRole = "admin"
    
    // Define all possible tab items with unique identifiers
    private let allTabItems: [(id: Int, role: [String], name: String, icon: String)] = [
        (0, ["client", "seller", "manager", "admin"], "Catalogue", "house"),
        (1, ["seller"], "Bilan", "chart.bar"),
        (2, ["manager", "admin"], "Utilisateurs", "person.3.fill"),
        (3, ["manager", "admin"], "Jeux", "gamecontroller.fill"),
        (4, ["manager", "admin"], "Transactions", "creditcard.fill"),
        (5, ["admin"], "Sessions", "calendar.badge.exclamationmark"),
        (6, ["seller", "manager", "admin"], "Profile", "person.fill"),
        (7, ["client"], "Connexion", "person.circle")
    ]
    
    // Define expandable menus
    private var expandableMenus: [String: [TabItem.MenuItem]] {
        var menus: [String: [TabItem.MenuItem]] = [
            "Utilisateurs": [
                TabItem.MenuItem(icon: "person.fill", title: "Clients"),
                TabItem.MenuItem(icon: "cart.fill", title: "Vendeurs"),
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
        
        // Only admins can see the Managers subtab
        if userRole == "admin" {
            menus["Utilisateurs"]?.append(TabItem.MenuItem(icon: "briefcase.fill", title: "Managers"))
        }
        
        return menus
    }
    
    // Filter tabs based on role and keep their original IDs
    private var filteredTabItems: [(id: Int, name: String, icon: String)] {
        allTabItems
            .filter { canAccessTab($0.role) }
            .map { ($0.id, $0.name, $0.icon) }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    // Use the selectedTab's ID to determine which view to show
                    if let selectedItem = filteredTabItems.first(where: { $0.id == selectedTab }) {
                        switch selectedItem.id {
                        case 0:
                            HomeView()
                        case 1:
                            BalanceView()
                        case 2:
                            if selectedSubTab == "Clients" {
                                ClientsListView()
                            } else if selectedSubTab == "Managers" {
                                ManagersListView()
                            } else if selectedSubTab == "Vendeurs" {
                                SellersListView()
                            } else {
                                PlaceholderView(title: "Utilisateurs", icon: "person.3.fill")
                            }
                        case 3:
                            if selectedSubTab == "Jeux" {
                                GamesListView()
                            } else if selectedSubTab == "Editeurs" {
                                GameEditorsListView()
                            } else if selectedSubTab == "Catégories" {
                                GameCategoriesListView()
                            } else {
                                PlaceholderView(title: "Jeux", icon: "gamecontroller.fill")
                            }
                        case 4:
                            if selectedSubTab == "Dépôts" {
                                DepositsListView()
                            } else if selectedSubTab == "Ventes" {
                                SalesListView()
                            } else if selectedSubTab == "Retraits" {
                                WithdrawalsListView()
                            } else if selectedSubTab == "Bilan" {
                                BalanceView()
                            } else {
                                PlaceholderView(title: "Transactions", icon: "creditcard.fill")
                            }
                        case 5:
                            SessionsListView()
                        case 6:
                            ProfileView()
                        case 7:
                            LoginView()
                        default:
                            HomeView()
                        }
                    } else {
                        // Fallback to HomeView if something goes wrong
                        HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                customTabBar
            }
            .zIndex(0)
            
            // Expandable Menu Overlay
            if let menu = expandedMenu {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            expandedMenu = nil
                        }
                    }
                    .zIndex(1)
                
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ForEach(menu.items, id: \.title) { item in
                            ExpandableTabButton(icon: item.icon, text: item.title) {
                                selectedSubTab = item.title
                                withAnimation(.spring()) {
                                    expandedMenu = nil
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom))
                }
                .zIndex(2)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            // Set initial tab to the first available tab for this user
            if let firstItem = filteredTabItems.first {
                selectedTab = firstItem.id
            }
        }
    }
    
    // Custom Tab Bar View
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(filteredTabItems, id: \.id) { item in
                let isExpendable = isExpandableTab(item.name)
                
                Button {
                    if isExpendable {
                        toggleMenu(name: item.name)
                    } else {
                        withAnimation {
                            selectedTab = item.id
                            selectedSubTab = nil
                            expandedMenu = nil
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if isExpendable && expandedMenu?.name == item.name {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: item.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text(item.name)
                            .font(.system(size: 10))
                            .padding(.bottom, 30)
                    }
                    .foregroundColor(selectedTab == item.id ? .blue : .gray)
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
    
    private func isExpandableTab(_ name: String) -> Bool {
        return expandableMenus.keys.contains(name)
    }
    
    private func toggleMenu(name: String) {
        withAnimation(.spring()) {
            if expandedMenu?.name == name {
                expandedMenu = nil
            } else {
                if let items = expandableMenus[name] {
                    expandedMenu = TabItem(name: name, items: items)
                    if let index = filteredTabItems.firstIndex(where: { $0.name == name }) {
                        selectedTab = filteredTabItems[index].id
                    }
                }
            }
        }
    }
    
    // Updated access control logic
    private func canAccessTab(_ roles: [String]) -> Bool {
        return roles.contains(userRole)
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
