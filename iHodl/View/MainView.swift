//
//  MainView.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var settings = Settings()
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            /// coming sooner...
//            Text("Portfolio")
//                .tabItem {
//                    Label("Potfolio", systemImage: "chart.pie")
//                }
//                .tag(0)
            MarketView()
                .tabItem {
                    Label(settings.marketTitle, systemImage: "chart.xyaxis.line")
                }
                .tag(0)
            /// coming soon...
//            Text("News")
//                .tabItem {
//                    Label("News", systemImage: "newspaper")
//                }
//                .tag(2)
            SettingsView()
                .tabItem {
                    Label(settings.settingsTitle, systemImage: "gear")
                }
                .tag(1)
        }
        .environmentObject(settings)
        .accentColor(.primary)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
