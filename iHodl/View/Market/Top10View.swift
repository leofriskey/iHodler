//
//  Top10View.swift
//  iHodl
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI

struct Top100View: View {
    
    //let coin: Int
    let coin: Coin_Preview
    
    var body: some View {
        ZStack {
            ZStack {
                // MARK: Coin price & price change
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.2))
                            .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.1)
                        Spacer()
                        if coin.price_change_24h > 0 {
                            HStack {
                                Text("+\(coin.price_change_24h.formatted(.currency(code: "usd")))    (+\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%)")
                                    .foregroundColor(.green)
                                    .font(.system(size: 15))
                                    
                            }
                            .font(.system(size: 14))
                        } else if coin.price_change_24h == 0 {
                            HStack {
                                Text("\(coin.price_change_24h.formatted(.currency(code: "usd")))    (\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%)")
                                    .font(.system(size: 15))
                            }
                        }
                        else {
                            HStack {
                                Text("\(coin.price_change_24h.formatted(.currency(code: "usd")))    (\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%)")
                                    .foregroundColor(.red)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    Spacer()
                    Text("\(coin.current_price.formatted(.currency(code: "usd")))")
                        .font(.system(size: 17))
                }
            }
            .padding(.bottom, UIScreen.screenHeight * 0.025)
            .padding([.horizontal, .top], 10)
            .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.18)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            // MARK: Coin logo, symbol, name, rank
            let url = URL(string: coin.image)
            HStack {
                Text("\(coin.market_cap_rank)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                AsyncImage(
                    url: url,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                VStack(alignment: .leading) {
                    Text(coin.name)
                    Text(coin.symbol.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.screenWidth * 0.8, alignment: .leading)
            .offset(x: -UIScreen.screenWidth * 0.08, y: UIScreen.screenHeight * 0.087)
        }
        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.18)
    }
}
