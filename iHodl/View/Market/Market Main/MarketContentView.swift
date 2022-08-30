//
//  MarketContentView.swift
//  iHodl
//
//  Created by Leo Friskey on 15.08.2022.
//

import SwiftUI

struct MarketContentView: View, Themeable {
    
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    @Environment(\.colorScheme) internal var colorScheme
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @State private var watchlistID = "watchlistID"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ScrollViewReader { (scrollProxy: ScrollViewProxy) in
                //MARK: Content
                
                if isSearching == false {
                    
                    //MARK: Watchlist
                    VStack {
                        HStack {
                            Text(settings.watchlistTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        
                        if market.watchlist.isEmpty {
                            //MARK: Watchlist text about
                            Text(settings.watchlistAbout)
                                .fontWeight(.light)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                        } else {
                            //MARK: Watchlist coins
                            WatchlistCoinsView(watchlistID: watchlistID)
                        }
                        
                        // Spacer
                        Color.clear
                            .frame(height: UIScreen.screenHeight * 0.08)
                        
                        //MARK: Top 10
                        HStack {
                            Text(settings.top10Title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        
                            //MARK: Global chart
                        GlobalView()
                            .padding(.vertical)
                        
                            //MARK: Top 10 Coins
                        Top10CoinsView()
                    }
                }
                //MARK: Search
                if isSearching == true {
                    SearchView(scrollProxy: scrollProxy, watchlistID: watchlistID)
                }
            }
        }
        //MARK: Pull to refresh
        .refreshable {
            Task {
                do {
                    // fetch data on scroll refresh
                    try await market.fetchWatchlist()
                    try await market.fetchTop10Coins()
                    try await market.fetchGlobal()
                } catch {
                    print("Failed to fetch data on scroll refresh: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: isSearching) { newValue in
            //MARK: delete cached search results
            if newValue == false {
                market.deleteCachedSearch()
            }
        }
    }
}

struct MarketContentView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environmentObject(Market()).environment(\.colorScheme, .dark)
    }
}
