//
//  SearchedCoinView.swift
//  iHodl
//
//  Created by Leo Friskey on 22.08.2022.
//

import SwiftUI

struct SearchedCoinView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    let coin: SearchedCoin
    
    var body: some View {
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
                Image(systemName: "questionmark")
                    .foregroundColor(.secondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                    )
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
    }
}
