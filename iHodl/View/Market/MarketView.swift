//
//  MarketView.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

struct MarketView: View {
    
    @EnvironmentObject private var market: Market
    let timer = Timer.publish(every: 20, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // background color
                LinearGradient.darkBG
                    .ignoresSafeArea()
                // MARK: Main content
                MarketContentView()
                    .searchable(text: $market.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .onSubmit(of: .search) {
                        // check if search text length is >= 3
                        if market.searchText.count >= 3 {
                            market.searchLengthIsEnough = true
                            Task {
                                // fetch searched coins
                                await market.searchForCoins(market.searchText)
                            }
                        } else {
                            market.searchLengthIsEnough = false
                        }
                    }
                    .errorAlert(error: $market.error)
            }
            .task {
                do {
                    // fetch top 10 coins on appear
                    //try await market.fetchWatchlist()
                    print("fetch watchlist: task")
                    try await market.fetchTop10Coins()
                    print("fetch top10: task")
                } catch {
                    print("Failed to fetch data on appear: \(error.localizedDescription)")
                }
            }
            .navigationTitle(market.title)
            .toolbar {
                // MARK: Toolbar control
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    // MARK: time interval
                    Picker("Choose time interval: 1D or 7D", selection: $market.timeInterval) {
                        ForEach(market.timeIntervals, id: \.self) { interval in
                            Text(interval)
                        }
                    }
                    .shadow(radius: 1, x: 0, y: 1)
                    .pickerStyle(.segmented)
                    // MARK: price notifications
                    Button {
                        // price notifications
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
                    // fetch coins every 15 seconds
                    //try await market.fetchWatchlist()
                    print("fetch watchlist: time")
                    try await market.fetchTop10Coins()
                    print("fetch top10: time")
                } catch {
                    print("Failed to fetch coins with time: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
