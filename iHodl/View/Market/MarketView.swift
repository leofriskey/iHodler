//
//  MarketView.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

struct MarketView: View {
    
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var network: Network
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var animateNetworkWarnBorder = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // background color
                (colorScheme == .dark ? LinearGradient.darkBG
                    .ignoresSafeArea() : LinearGradient.lightBG.ignoresSafeArea())
                // MARK: Main content
                MarketContentView()
                    .searchable(text: $market.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .disabled(network.connected == false ? true : false)
                    .blur(radius: network.connected == false ? 7 : 0)
                    .onSubmit(of: .search) {
                        // check if search text length is >= 3
                        if market.searchText.count >= 3 {
                            market.searchLengthIsEnough = true
                            market.searchNotFound = false
                            Task {
                                // fetch searched coins
                                await market.searchForCoins(market.searchText)
                            }
                        } else {
                            market.searchLengthIsEnough = false
                        }
                    }
                    .errorAlert(error: $market.error)
                if network.connected == false {
                    ZStack {
                        colorScheme == .dark ?
                        Color.black
                            .opacity(0.2)
                            .ignoresSafeArea()
                        :
                        Color.white
                            .opacity(0.2)
                            .ignoresSafeArea()
                        VStack {
                            Spacer()
                            Label("Check your internet connection", systemImage: "wifi.exclamationmark")
                                .frame(width: 300, height: 30)
                                .background(

                                    colorScheme == .dark ?
                                    LinearGradient.material02dark
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 16)
                                        )
                                        .shadow(radius: 2, x: -4, y: 4)
                                        .shadow(radius: 2, x: 4, y: -4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(animateNetworkWarnBorder ? .red : .clear)
                                                .onAppear {
                                                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                                        self.animateNetworkWarnBorder.toggle()
                                                    }
                                                }
                                        )
                                    :
                                    LinearGradient.material02light
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 16)
                                        )
                                        .shadow(radius: 2, x: -4, y: 4)
                                        .shadow(radius: 2, x: 4, y: -4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(animateNetworkWarnBorder ? .red : .clear)
                                                .onAppear {
                                                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                                        self.animateNetworkWarnBorder.toggle()
                                                    }
                                                }
                                        )

                                )
                                .padding()
                        }
                    }
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
                    .pickerStyle(.segmented)
                    .disabled(network.connected == false ? true : false)
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
        .onReceive(market.coinsTimer) { time in
            Task {
                do {
                    // fetch data every 20 seconds
                    try await market.fetchWatchlist()
                    try await market.fetchTop10Coins()
                    try await market.fetchGlobal()
                } catch {
                    print("Failed to fetch data with time: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            // check internet connection
            network.checkConnection()
            for i in market.watchlist {
                print(i.sparkline7D.price?.count ?? 0)
            }
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
