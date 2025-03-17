//
//  TabBarView.swift
//  app-ios-awi
//
//  Created by etud on 17/03/2025.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var expandedMenu: TabItem? = nil
    
    // Define all tab items
    private let tabItems = [
        ("Home", "house"),
        ("Users", "person.3.fill"),
        ("Games", "gamecontroller.fill"),
        ("Transactions", "creditcard.fill"),
        ("Sessions", "clock.fill"),
        ("Login", "person.circle")
    ]
    
    // Define expandable menus
    private let expandableMenus: [String: [TabItem.MenuItem]] = [
        "Users": [
            TabItem.MenuItem(icon: "person.fill", title: "Clients"),
            TabItem.MenuItem(icon: "cart.fill", title: "Sellers"),
            TabItem.MenuItem(icon: "briefcase.fill", title: "Managers")
        ],
        "Games": [
            TabItem.MenuItem(icon: "gamecontroller", title: "Games"),
            TabItem.MenuItem(icon: "paintbrush", title: "Editors"),
            TabItem.MenuItem(icon: "list.bullet", title: "Categories")
        ],
        "Transactions": [
            TabItem.MenuItem(icon: "dollarsign.circle", title: "Deposits"),
            TabItem.MenuItem(icon: "bag.fill", title: "Sales"),
            TabItem.MenuItem(icon: "arrow.down.circle", title: "Withdrawals"),
            TabItem.MenuItem(icon: "chart.bar", title: "Bilan")
        ]
    ]
    
    var body: some View {
        ZStack {
            // Content based on selected tab
            VStack {
                Spacer()
                switch selectedTab {
                case 0:
                    HomeView()
                case 1:
                    PlaceholderView(title: "Users")
                case 2:
                    PlaceholderView(title: "Games")
                case 3:
                    PlaceholderView(title: "Transactions")
                case 4:
                    PlaceholderView(title: "Sessions")
                case 5:
                    LoginView()
                default:
                    HomeView()
                }
                Spacer()
                
                // Custom Tab Bar
                customTabBar
            }
            
            // Expandable Menu Overlay
            if let menu = expandedMenu {
                VStack {
                    Spacer()
                    
                    // Dimmed background overlay when menu is expanded
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                expandedMenu = nil
                            }
                        }
                    
                    // Menu items
                    VStack(spacing: 12) {
                        ForEach(menu.items, id: \.title) { item in
                            ExpandableTabButton(icon: item.icon, text: item.title) {
                                print("\(item.title) tapped")
                                withAnimation(.spring()) {
                                    expandedMenu = nil
                                }
                            }
                        }
                    }
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom))
                }
                .zIndex(1)
            }
        }
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
                            // Close any open menu when switching tabs
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
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Check if a tab is expandable
    private func isExpandableTab(_ name: String) -> Bool {
        return expandableMenus.keys.contains(name)
    }
    
    // Toggle expandable menu
    private func toggleMenu(name: String) {
        withAnimation(.spring()) {
            if expandedMenu?.name == name {
                expandedMenu = nil  // Close if already open
            } else {
                if let items = expandableMenus[name] {
                    expandedMenu = TabItem(name: name, items: items)
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
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title)
                .fontWeight(.medium)
            
            Text("Select an option from the menu")
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
