//
//  MarketView.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

struct MarketView: View {
    
    @EnvironmentObject private var market: Market
    let timer = Timer.publish(every: 8, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var top100Coins = [Coin_Preview]()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.darkBG
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack {
                        // MARK: Top 100
                        HStack {
                            Text(market.top100Title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        HStack {
                            Text("Coin")
                                .fontWeight(.light)
                                .font(.caption)
                            Spacer()
                            Text("Price")
                                .fontWeight(.light)
                                .font(.caption)
                            Spacer()
                            Text("1D %")
                                .fontWeight(.light)
                                .font(.caption)
                        }
                        .frame(maxWidth: UIScreen.screenWidth * 0.8)
                        VStack(spacing: 40) {
                            ForEach(top100Coins) { coin in
                                NavigationLink {
                                    Text("Detail View")
                                } label: {
                                    Top100View(coin: coin)
                                    .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.18)
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .task {
                do {
                    try await market.fetchTop100Coins()
                } catch {
                    print("Failed to fetch data on appear: \(error.localizedDescription)")
                }
            }
            .navigationTitle(market.title)
        }
        .onReceive(timer) { time in
            Task {
                do {
                    try await market.fetchTop100Coins()
                    self.top100Coins = market.top100Coins
                } catch {
                    print("Failed to fetch data with time: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(market.$top100Coins) { newData in
            withAnimation(.easeOut(duration: 0.5)) {
                self.top100Coins = newData
            }
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
