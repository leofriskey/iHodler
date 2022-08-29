//
//  MarketView.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

struct MarketView: View, Themeable {
    
    @EnvironmentObject private var market: Market
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var network: Network
    
    @Environment(\.colorScheme) internal var colorScheme
    
    @State private var animateNetworkWarnBorder = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: Background
                BackgroundColor.ignoresSafeArea()
                
                
                //MARK: Main content
                MarketContentView()
                    .searchable(text: $market.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .disabled(network.connected == false ? true : false)
                    .blur(radius: network.connected == false ? 7 : 0)
                    .onSubmit(of: .search) {
                        Task {
                            await market.validateSearch()
                        }
                    }
                    .onReceive(market.errorTimer) { _ in
                        market.reduceErrorTime()
                    }
                // no internet connectivity
                if network.connected == false {
                    ZStack {
                        // dim the lights
                        Material02.ignoresSafeArea()
                        VStack {
                            Spacer()
                            // show warning
                            Label("Check your internet connection", systemImage: "wifi.exclamationmark")
                                .frame(width: 300, height: 30)
                                .background(

                                    Material02
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
            .navigationTitle(settings.marketTitle)
            .toolbar {
                //MARK: Toolbar control
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    
                    //MARK: time interval
                    Picker("Choose time interval: 1 day or 7 days", selection: $market.marketInterval) {
                        ForEach(market.marketIntervals, id: \.self) { interval in
                            Text(interval)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(network.connected == false ? true : false)
                }
            }
        }
        .errorAlert(error: $market.error, remainingTime: $market.errorTime) // show alert when api limit hit
        .onReceive(market.marketTimer) { time in
            guard market.marketTimerIsActive else { return }
            
            Task {
                do {
                    // fetch data every 30 seconds
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
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market()).environmentObject(Network())
    }
}
