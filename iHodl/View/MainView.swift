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
        TabView {
            Text("Portfolio")
                .tabItem {
                    Label("Portfolio", systemImage: "chart.pie.fill")
                }
                .tag(0)
            Text("Market")
                .tabItem {
                    Label("Market", systemImage: "chart.xyaxis.line")
                }
                .tag(1)
            Text("News")
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
                .tag(2)
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(.primary)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(ViewRouter())
    }
}
