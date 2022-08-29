//
//  WatchlistCoinsView.swift
//  iHodl
//
//  Created by Leo Friskey on 28.08.2022.
//

import SwiftUI

struct WatchlistCoinsView: View, Themeable {
    
    @Environment(\.colorScheme) internal var colorScheme
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    
    let watchlistID: String
    
    var body: some View {
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
                Text("\(market.marketInterval) %")
                    .fontWeight(.light)
                    .font(.caption)
            }
            .frame(maxWidth: UIScreen.screenWidth * 0.8)
            ForEach(market.watchlist.sorted { ($0.marketCapRank ?? 0) < ($1.marketCapRank ?? 1) }) { coin in
                NavigationLink {
                    CoinDetailView(anyCoin: coin)
                } label: {
                    CoinPreviewView(coin: coin, interval: market.marketInterval)
                    .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.23)
                    //MARK: Watchlist context menu
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
                    } preview: {
                        CoinPreviewView(coin: coin, interval: market.marketInterval)
                            .environmentObject(market)
                        .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.22)
                        .background(BackgroundColor)
                    }
                }
            }
            .disabled(market.watchlist.first?.symbol == "placeholder" ? true : false)
        }
        .id(watchlistID)
    }
}

struct WatchlistCoinsView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistCoinsView(watchlistID: "watchlistID")
    }
}
