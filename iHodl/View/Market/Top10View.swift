//
//  Top10View.swift
//  iHodl
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI

struct Top10View: View {
    
    let coin: Coin_Preview
    let interval: String
    
    var body: some View {
        ZStack {
            // MARK: Coin price & price change
            
            
            ZStack {
                // MARK: 1D intrerval
                if interval == "1D" {
                    let last24 = coin.sparkline_in_7d.price.suffix(24)
                    let sparkline_1d = Array(last24)
                    VStack {
                        // MARK: price go up
                        if coin.price_change_percentage_24h_in_currency > 0 {
                            HStack {
                                miniLineGraphView(data: sparkline_1d.map { CGFloat($0) }, lineGradient: [.green.opacity(0.7), .green], bgGradient: [.green.opacity(0.3), .green.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack(spacing: 3) {
                                    Text("+\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price change is 0
                        } else if coin.price_change_percentage_24h_in_currency == 0 {
                            HStack {
                                miniLineGraphView(data: sparkline_1d.map { CGFloat($0) }, lineGradient: [.secondary.opacity(0.7), .secondary], bgGradient: [.secondary.opacity(0.3), .secondary.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price go down
                        } else {
                            HStack {
                                miniLineGraphView(data: sparkline_1d.map { CGFloat($0) }, lineGradient: [.red.opacity(0.7), .red], bgGradient: [.red.opacity(0.3), .red.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.price_change_percentage_24h_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        }
                        Spacer()
                        Text("\(coin.current_price.formatted(.currency(code: "usd")))")
                            .font(.system(size: 18))
                    }
                    // MARK: 7D intrerval
                } else { // 7D
                    
                    
                    VStack {
                        // MARK: price go up
                        if coin.price_change_percentage_7d_in_currency > 0 {
                            HStack {
                                miniLineGraphView(data: coin.sparkline_in_7d.price.map { CGFloat($0) }, lineGradient: [.green.opacity(0.7), .green], bgGradient: [.green.opacity(0.3), .green.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("+\(coin.price_change_percentage_7d_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price change is 0
                        } else if coin.price_change_percentage_7d_in_currency == 0 {
                            HStack {
                                miniLineGraphView(data: coin.sparkline_in_7d.price.map { CGFloat($0) }, lineGradient: [.secondary.opacity(0.7), .secondary], bgGradient: [.secondary.opacity(0.3), .secondary.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("+\(coin.price_change_percentage_7d_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price go down
                        } else {
                            HStack {
                                miniLineGraphView(data: coin.sparkline_in_7d.price.map { CGFloat($0) }, lineGradient: [.red.opacity(0.7), .red], bgGradient: [.red.opacity(0.3), .red.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.price_change_percentage_7d_in_currency, specifier: "%.2f")%")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        }
                        Spacer()
                        Text("\(coin.current_price.formatted(.currency(code: "usd")))")
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.bottom, UIScreen.screenHeight * 0.025)
            .padding([.horizontal, .top], 10)
            .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.18)
            .background(
                LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.33)], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.2)
            )
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
