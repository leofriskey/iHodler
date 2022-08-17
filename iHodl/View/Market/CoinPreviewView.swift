//
//  CoinPreviewView.swift
//  iHodl
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI

struct CoinPreviewView: View {
    
    let coin: CoinPreview
    let interval: String
    
    @State private var sparkline = [Double]()
    @State private var darken = false
    
    var body: some View {
        ZStack {
            // MARK: Coin price & price change
            
            ZStack {
                // MARK: 1D intrerval
                if interval == "1D" {
                    VStack {
                        // MARK: price go up
                        if coin.priceChangePercentage24HInCurrency ?? 0 > 0 {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.green.opacity(0.7), .green], bgGradient: [.green.opacity(0.3), .green.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack(spacing: 3) {
                                    Text("+\(coin.priceChangePercentage24HInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price change is 0
                        } else if coin.priceChangePercentage24HInCurrency == 0 {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.secondary.opacity(0.7), .secondary], bgGradient: [.secondary.opacity(0.3), .secondary.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.priceChangePercentage24HInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price go down
                        } else {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.red.opacity(0.7), .red], bgGradient: [.red.opacity(0.3), .red.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.priceChangePercentage24HInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        }
                        Spacer()
                        Text("\(coin.currentPrice.formatted(.currency(code: "usd")))")
                            .font(.system(size: 18))
                            .opacity(darken ? 0.3 : 1)
                    }
                    .onAppear {
                        sparkline = coin.sparkline7D.price?.suffix(24) ?? Array(repeating: 0.00, count: 24)
                    }
                    // MARK: 7D intrerval
                } else { // 7D
                    
                    
                    VStack {
                        // MARK: price go up
                        if coin.priceChangePercentage7DInCurrency ?? 0 > 0 {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.green.opacity(0.7), .green], bgGradient: [.green.opacity(0.3), .green.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("+\(coin.priceChangePercentage7DInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price change is 0
                        } else if coin.priceChangePercentage7DInCurrency == 0 {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.secondary.opacity(0.7), .secondary], bgGradient: [.secondary.opacity(0.3), .secondary.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("+\(coin.priceChangePercentage7DInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                }
                            }
                        // MARK: price go down
                        } else {
                            HStack {
                                SparklineView(coin: coin, data: sparkline.map { CGFloat($0) }, lineGradient: [.red.opacity(0.7), .red], bgGradient: [.red.opacity(0.3), .red.opacity(0)])
                                    .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
                                Spacer()
                                HStack {
                                    Text("\(coin.priceChangePercentage7DInCurrency ?? 0, specifier: "%.2f")%")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                        .padding(.top)
                                        .opacity(darken ? 0.3 : 1)
                                }
                            }
                        }
                        Spacer()
                        Text("\(coin.currentPrice.formatted(.currency(code: "usd")))")
                            .font(.system(size: 18))
                            .opacity(darken ? 0.3 : 1)
                    }
                    .onAppear {
                        sparkline = coin.sparkline7D.price ?? Array(repeating: 0.00, count: 24)
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
            .onChange(of: coin.currentPrice) { _ in
                // make data blink on update
                darken = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        darken = false
                    }
                }
            }
            // MARK: Coin logo, symbol, name, rank
            //let url = URL(string: coin.image)
            HStack {
                if coin.marketCapRank != nil {
                    Text("\(coin.marketCapRank!)")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                        }
                    )
                } else {
                    Image(systemName: "questionmark")
                        .frame(width: 32, height: 32)
                }
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
