//
//  MainView.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewRouter: ViewRouter
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
                    Label("Market", systemImage: "chart.xyaxis.line")
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
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
        .accentColor(.primary)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
