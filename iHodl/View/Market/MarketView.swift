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
    
    @State private var top10Coins = [Coin_Preview]()
    
    let sampleGraphData: [CGFloat] = [900, 1400, 984, 1020, 1080, 300, 1010, 900, 1100]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.darkBG
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack {
                        // MARK: Top 10
                        HStack {
                            Text(market.top10Title)
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
                            ForEach(top10Coins) { coin in
                                NavigationLink {
                                    Text("Detail View")
                                } label: {
                                    Top10View(coin: coin, interval: market.timeInterval)
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
                    try await market.fetchTop10Coins()
                } catch {
                    print("Failed to fetch data on appear: \(error.localizedDescription)")
                }
            }
            .navigationTitle(market.title)
            .toolbar {
                // MARK: Toolbar controlw
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Picker("Choose time interval: 1D or 7D", selection: $market.timeInterval) {
                        ForEach(market.timeIntervals, id: \.self) { interval in
                            Text(interval)
                        }
                    }
                    .shadow(radius: 1, x: 0, y: 1)
                    .pickerStyle(.segmented)
                    Button {
                        //
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .onReceive(timer) { time in
            Task {
                do {
                    try await market.fetchTop10Coins()
                    self.top10Coins = market.top10Coins
                } catch {
                    print("Failed to fetch data with time: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(market.$top10Coins) { newData in
            withAnimation(.easeOut(duration: 0.5)) {
                self.top10Coins = newData
            }
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
