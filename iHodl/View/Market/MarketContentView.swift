//
//  MarketContentView.swift
//  iHodl
//
//  Created by Leo Friskey on 15.08.2022.
//

import SwiftUI

struct MarketContentView: View {
    
    @EnvironmentObject private var market: Market
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    
    @State private var fetchedCoin: Coin? = nil
    @State private var fetchedCoinIndex = 0
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if isSearching == false {
                VStack {
                    // MARK: Watchlist
                    HStack {
                        Text(market.watchlistTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    if market.watchlist.isEmpty {
                        Text(market.watchlistAbout)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Coin")
                                    .fontWeight(.light)
                                    .font(.caption)
                                Spacer()
                                Text("Price")
                                    .fontWeight(.light)
                                    .font(.caption)
                                Spacer()
                                Text("\(market.timeInterval) %")
                                    .fontWeight(.light)
                                    .font(.caption)
                            }
                            .frame(maxWidth: UIScreen.screenWidth * 0.8)
                            ForEach(market.watchlist.sorted { ($0.marketCapRank ?? 0) < ($1.marketCapRank ?? 1) }) { coin in
                                NavigationLink {
                                    Text("Detail View")
                                } label: {
                                    CoinPreviewView(coin: coin, interval: market.timeInterval)
                                    .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.22)
                                    .contextMenu {
                                        // remove coin from watchlist
                                        Button {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation {
                                                    market.removeFromWatchlist(coin)
                                                }
                                            }
                                        } label: {
                                            Label("Remove from watchlist", systemImage: "star.slash.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Color.clear
                        .frame(height: UIScreen.screenHeight * 0.08)
                    // MARK: Top 10
                    HStack {
                        Text(market.top10Title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding()
                    VStack(spacing: 0) {
                        HStack {
                            Text("Coin")
                                .fontWeight(.light)
                                .font(.caption)
                            Spacer()
                            Text("Price")
                                .fontWeight(.light)
                                .font(.caption)
                            Spacer()
                            Text("\(market.timeInterval) %")
                                .fontWeight(.light)
                                .font(.caption)
                        }
                        .frame(maxWidth: UIScreen.screenWidth * 0.8)
                        VStack(spacing: 20) {
                            ForEach(market.top10Coins) { coin in
                                NavigationLink {
                                    Text("Detail View")
                                } label: {
                                    CoinPreviewView(coin: coin, interval: market.timeInterval)
                                    .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.22)
                                    .contextMenu {
                                        // "add coin to watchlist" option if coin is not already there
                                        if !market.watchlist.contains(where: { $0.id == coin.id } ) {
                                            Button {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation {
                                                        market.addToWatchlistFromTop10(coin)
                                                    }
                                                }
                                            } label: {
                                                Label("Add to watchlist", systemImage: "star")
                                            }
                                        // "remove coin from watchlist" option if coin is already there
                                        } else {
                                            Button {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    withAnimation {
                                                        market.removeFromWatchlist(coin)
                                                    }
                                                }
                                            } label: {
                                                Label("Remove from watchlist", systemImage: "star.slash.fill")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 30)
                     }
                }
            }
            if isSearching == true {
                // check if search text length is >= 3 characters
                if market.searchLengthIsEnough {
                    // check if coins are not yet fetched -> show progress view
                    if market.searchedCoins.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    // show list of coins for search query (by name, id, symbol)
                    } else {
                        ForEach(market.searchedCoins) { coin in
                            NavigationLink {
                                Text("Detail View")
                            } label: {
                                HStack {
                                    if coin.marketCapRank != nil {
                                        Text("\(coin.marketCapRank!)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .frame(width: 34)
                                    } else {
                                        Text("")
                                            .font(.caption2)
                                            .frame(width: 34)
                                    }
                                    if coin.image != nil {
                                        AsyncImage(
                                            url: URL(string: coin.image!),
                                            content: { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 32, height: 32)
                                            },
                                            placeholder: {
                                                ProgressView()
                                                    .frame(width: 32, height: 32)
                                            }
                                        )
                                    } else {
                                        Image(systemName: "questionamrk")
                                            .frame(width: 32, height: 32)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(coin.name)
                                        Text(coin.symbol.uppercased())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("\(coin.currentPrice.formatted(.currency(code: "usd")))")
                                }
                                .padding(10)
                                .contextMenu {
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
                                        } label: {
                                            Label("Add to watchlist", systemImage: "star")
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
                                        } label: {
                                            Label("Remove from watchlist", systemImage: "star.slash.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Type at least 3 characters and press 'Search' to begin searching...")
                        .fontWeight(.light)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onChange(of: isSearching) { newValue in
            // delete cached search results
            if newValue == false {
                market.searchLengthIsEnough = false
                market.searchedCoins = []
            }
        }
        .onAppear {
            // set placeholder for top10 before coins are fetched from the api
            market.setPlaceholderTop10()
        }
    }
}

struct MarketContentView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environmentObject(Market()).environment(\.colorScheme, .dark)
    }
}
