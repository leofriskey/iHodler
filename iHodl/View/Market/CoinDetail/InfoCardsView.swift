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

struct InfoCardsView: View {
    
    @EnvironmentObject private var market: Market
    @Environment(\.colorScheme) private var colorScheme
    
    let coin: Coin
    let type: InfoCards
    let currency = "usd"
    
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
                    if let fiatVolume = coin.marketData.totalVolume?[currency] {
                        Text("\(fiatVolume.formatted(.currency(code: currency)))")
                            .font(.system(size: 16))
                        if let cryptoVolume = coin.marketData.totalVolume?[coin.symbol.lowercased()] {
                            Text("\(Int(cryptoVolume)) \(coin.symbol.uppercased())")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(market.noData)
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
                    .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
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
                    if let marketCap = coin.marketData.marketCap?[currency] {
                        Text("\(marketCap.formatted(.currency(code: currency)))")
                            .font(.system(size: 16))
                        if let marketCapRank = coin.marketCapRank {
                            Text("rank \(marketCapRank)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(market.noData)
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
                    .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
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
//                            HStack {
//                                RoundedRectangle(cornerRadius: 4)
//                                    .fill(.ultraThinMaterial)
//                                    .frame(width: 120, height: 5)
//                                    .overlay(alignment: .leading, content: {
//                                        RoundedRectangle(cornerRadius: 4)
//                                            .fill(colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
//                                            .frame(width: 120 * (supply / maxSupply), height: 5)
//                                    })
//                                Text("\(Int(Double(supply) / Double(maxSupply))) %")
//                                    .font(.system(size: 14))
//                            }
                        }
                    } else {
                        Text(market.noData)
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
                    .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
            )
        }
    }
}
