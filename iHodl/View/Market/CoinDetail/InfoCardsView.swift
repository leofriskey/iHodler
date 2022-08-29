//
//  InfoCardsView.swift
//  iHodl
//
//  Created by Leo Friskey on 26.08.2022.
//

import SwiftUI

enum InfoCards {
    case volume, marketCap, supply
}

struct InfoCardsView: View, Themeable {
    
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    @Environment(\.colorScheme) internal var colorScheme
    
    let coin: Coin
    let type: InfoCards
    
    var body: some View {
        switch type {
        case .volume:
            VStack(spacing: 5) {
                HStack {
                    Text("Volume 1D")
                        .font(.system(size: 14))
                        .fontWeight(.light)
                    Spacer()
                }
                .padding([.leading, .top], 10)
                VStack {
                    if let fiatVolume = coin.marketData.totalVolume?[market.currency] {
                        Text("\(fiatVolume.formatAsPrice(currency: market.currency, afterZero: 0))")
                            .font(.system(size: 16))
                        if let cryptoVolume = coin.marketData.totalVolume?[coin.symbol.lowercased()] {
                            Text("\(Int(cryptoVolume)) \(coin.symbol.uppercased())")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(settings.noData)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(5)
                
            }
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Material02)
            )
        case .marketCap:
            VStack(spacing: 5) {
                HStack {
                    Text("Market Cap")
                        .font(.system(size: 14))
                        .fontWeight(.light)
                    Spacer()
                }
                .padding([.leading, .top], 10)
                VStack {
                    if let marketCap = coin.marketData.marketCap?[market.currency] {
                        Text("\(marketCap.formatAsPrice(currency: market.currency, afterZero: 0))")
                            .font(.system(size: 16))
                        if let marketCapRank = coin.marketCapRank {
                            Text("rank \(marketCapRank)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(settings.noData)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(5)
                
            }
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Material02)
            )
        case .supply:
            VStack(spacing: 5) {
                HStack {
                    Text("Circulating Supply")
                        .font(.system(size: 14))
                        .fontWeight(.light)
                    Spacer()
                }
                .padding([.leading, .top], 10)
                VStack {
                    if let supply = coin.marketData.circulatingSupply {
                        Text("\(Int(supply)) \(coin.symbol.uppercased())")
                            .font(.system(size: 16))
                        if let maxSupply = coin.marketData.maxSupply {
                            Text("/ \(Int(maxSupply)) \(coin.symbol.uppercased())")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(settings.noData)
                            .fontWeight(.light)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(5)
                
            }
            .frame(height: 80)
            .background(
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Material02)
                    if let supply = coin.marketData.circulatingSupply {
                        if let maxSupply = coin.marketData.maxSupply {
                            RoundedRectangle(cornerRadius: 18)
                                .frame(height: 80)
                                .mask(alignment: .bottom, {
                                    Material02.frame(height: 80 * (supply / maxSupply))
                                })
                        }
                    }
                }
            )
        }
    }
}
