//
//  WatchlistCoinsView.swift
//  iHodler
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
        VStack(alignment: .custom, spacing: 0) {
            HStack(alignment: .center) {
                Text(settings.coinCaption)
                    .fontWeight(.light)
                    .font(.caption)
                Spacer()
                Text(settings.priceCaption)
                    .fontWeight(.light)
                    .font(.caption)
                    .alignmentGuide(.custom) { $0[HorizontalAlignment.center] } // <- always center Price
                Spacer()
                if market.marketInterval == "1D" {
                    Text("\(settings.d1Title) %")
                        .fontWeight(.light)
                        .font(.caption)
                } else {
                    Text("\(settings.d7Title) %")
                        .fontWeight(.light)
                        .font(.caption)
                }
            }
            .frame(maxWidth: UIScreen.screenWidth * 0.8)
            ForEach(market.watchlist.sorted { ($0.marketCapRank ?? 0) < ($1.marketCapRank ?? 1) }) { coin in
                NavigationLink {
                    CoinDetailView(anyCoin: coin)
                } label: {
                    CoinPreviewView(coin: coin, interval: market.marketInterval)
                    .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.22)
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
                            Label(settings.removeFromWatchlistTitle, systemImage: "star.slash.fill")
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
