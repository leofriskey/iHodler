//
//  SearchedCoinView.swift
//  iHodl
//
//  Created by Leo Friskey on 22.08.2022.
//

import SwiftUI

struct SearchedCoinView: View, Themeable {
    
    @Environment(\.colorScheme) internal var colorScheme
    
    @EnvironmentObject private var market: Market
    
    let coin: SearchedCoin
    
    var body: some View {
        HStack {
            // We have marcetCap rank
            if coin.marketCapRank != nil {
                Text("\(coin.marketCapRank!)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 34)
            // We DONT have marcetCap rank
            } else {
                Text("")
                    .font(.caption2)
                    .frame(width: 34)
            }
            // We have an image
            if coin.image != nil {
                AsyncImage(
                    url: URL(string: coin.image!),
                    content: { image in
                        // real image
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    },
                    // placeholder
                    placeholder: {
                        ProgressView()
                            .frame(width: 32, height: 32)
                    }
                )
            // We dont have an image
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Material05)
                    )
            }
            // name & symbol
            VStack(alignment: .leading) {
                Text(coin.name)
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // price
            Text("\(coin.currentPrice.formatAsPrice(currency: market.currency))")
        }
    }
}
