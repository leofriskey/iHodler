//
//  SearchView.swift
//  iHodl
//
//  Created by Leo Friskey on 28.08.2022.
//

import SwiftUI

struct SearchView: View, Themeable {
    
    @Environment(\.colorScheme) internal var colorScheme
    @EnvironmentObject private var market: Market
    @Environment(\.dismissSearch) private var dismissSearch
    @EnvironmentObject private var settings: Settings
    
    let scrollProxy: ScrollViewProxy
    let watchlistID: String
    
    var body: some View {
        // check if search text length is >= 3 characters
        if market.searchLengthIsEnough {
            // check if coins are not yet fetched -> show progress view
            if market.searchedCoins.isEmpty && market.searchNotFound == false {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            // if nothing is found for given search query
            if market.searchedCoins.isEmpty && market.searchNotFound == true {
                Text(settings.noCoinsForSearchQuery)
                    .fontWeight(.light)
            }
            // show list of coins for search query (by name, id, symbol)
            if !market.searchedCoins.isEmpty {
                ForEach(market.searchedCoins) { coin in
                    NavigationLink {
                        CoinDetailView(anyCoin: coin)
                    } label: {
                        SearchedCoinView(coin: coin)
                        .padding(10)
                    }.contextMenu {
                        // "add coin to watchlist" option if coin is not already there
                        if !market.watchlist.contains(where: { $0.id == coin.id } ) {
                            Button {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        // add placeholder while waiting for coin to fetch
                                        market.addToWatchlistFromSearchPlaceHolder()
                                        dismissSearch()
                                    }
                                    Task {
                                        // fetch coin, transform it for preview and replace placeholder with it
                                        try await market.addToWatchListFromSearch(id: coin.id)
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation {
                                        scrollProxy.scrollTo(watchlistID, anchor: .bottom)
                                    }
                                }
                            } label: {
                                Label(settings.addToWatchlistTitle, systemImage: "star")
                            }
                        // "remove coin from watchlist" option if coin is already there
                        } else {
                            Button {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        market.removeFromWatchlist(coin)
                                        dismissSearch()
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation {
                                        scrollProxy.scrollTo(watchlistID, anchor: .bottom)
                                    }
                                }
                            } label: {
                                Label(settings.removeFromWatchlistTitle, systemImage: "star.slash.fill")
                            }
                        }
                    } preview: {
                        SearchedCoinView(coin: coin)
                            .environmentObject(market)
                        .padding(10)
                        .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.07)
                        .background(BackgroundColor)
                    }
                }
            }
        //MARK: Search start suggestion
        } else {
            Text(settings.searchStartSuggestion)
                .fontWeight(.light)
                .foregroundColor(.secondary)
        }
    }
}
