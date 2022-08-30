//
//  MarketView.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

struct MarketView: View, Themeable {
    
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    
    @Environment(\.colorScheme) internal var colorScheme
    
    @State private var animateNetworkWarnBorder = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: Background
                BackgroundColor.ignoresSafeArea()
                
                
                //MARK: Main content
                MarketContentView()
                    .searchable(text: $market.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: settings.searchPrompt)
                    .onSubmit(of: .search) {
                        Task {
                            await market.validateSearch()
                        }
                    }
                    .onReceive(market.errorTimer) { _ in
                        market.reduceErrorTime()
                    }
            }
            .navigationTitle(settings.marketTitle)
            .toolbar {
                //MARK: Toolbar control
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    
                    //MARK: time interval
                    Picker("Choose time interval: 1 day or 7 days", selection: $market.marketInterval) {
                        ForEach(market.marketIntervals, id: \.self) { interval in
                            if interval == "1D" {
                                Text(settings.d1Title)
                            } else {
                                Text(settings.d7Title)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .errorAlert(error: $market.error, remainingTime: $market.errorTime) // show alert when api limit hit
        .onReceive(market.marketTimer) { time in
            guard market.marketTimerIsActive else { return }
            
            Task {
                do {
                    // fetch data every 30 seconds
                    try await market.fetchWatchlist()
                    try await market.fetchTop10Coins()
                    try await market.fetchGlobal()
                } catch {
                    print("Failed to fetch data with time: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            // disallow to rotate device
            AppDelegate.orientationLock = .portrait
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
