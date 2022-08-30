//
//  Top10CoinsView.swift
//  iHodler
//
//  Created by Leo Friskey on 28.08.2022.
//

import SwiftUI

struct Top10CoinsView: View, Themeable {
    
    @Environment(\.colorScheme) internal var colorScheme
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        VStack(alignment: .custom, spacing: 0) {
            HStack {
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
            LazyVStack(spacing: 20) {
                ForEach(market.top10Coins) { coin in
                    NavigationLink {
                        CoinDetailView(anyCoin: coin)
                    } label: {
                        CoinPreviewView(coin: coin, interval: market.marketInterval)
                        .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.2)
                        //MARK: Top10 context menu
                        .contextMenu {
                            // "add coin to watchlist" option if coin is not already there
                            if !market.watchlist.contains(where: { $0.id == coin.id } ) {
                                Button {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            market.addToWatchlist(coin)
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
                                        }
                                    }
                                } label: {
                                    Label(settings.removeFromWatchlistTitle, systemImage: "star.slash.fill")
                                }
                            }
                        } preview: {
                            CoinPreviewView(coin: coin, interval: market.marketInterval)
                                .environmentObject(market)
                            .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.22)
                            .background(BackgroundColor)
                        }
                    }
                }
                .disabled(market.top10Coins.first?.symbol == "placeholder" ? true : false)
            }
            .padding(.bottom, 30)
         }
        .padding(.top)
    }
}

struct Top10CoinsView_Previews: PreviewProvider {
    static var previews: some View {
        Top10CoinsView()
    }
}
