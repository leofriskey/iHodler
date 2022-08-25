//
//  CoinDetailView.swift
//  iHodl
//
//  Created by Leo Friskey on 20.08.2022.
//

import SwiftUI

struct CoinDetailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var market: Market
    
    let anyCoin: CryptoCurrency
    let currency = "usd"
    @State private var coin: Coin? = nil
    @State private var chart = [CoinChartData]()
    
    @State private var blinkPrice = false
    @State private var blinkChange = false
    
    @State private var expandedChart = false
    
    var body: some View {
        ZStack {
            // MARK: Background
            (colorScheme == .dark ? LinearGradient.darkBG.ignoresSafeArea() : LinearGradient.lightBG.ignoresSafeArea())
            
            ScrollView {
                VStack {
                    // MARK: Chart
                    ZStack {
                        ZStack {
                            // MARK: Chart
                            ZStack {
                                ZStack {
                                    GeometryReader { geo in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            ScrollViewReader { scroll in
                                                // chart
                                                if market.chartLoaded == true {
                                                    if coin != nil {
                                                        ChartView(coin: coin!, data: chart, interval: market.chartTimePicker, expanded: expandedChart)
                                                            .frame(maxHeight: UIScreen.screenHeight * 0.25)
                                                            .padding(.horizontal, 5)
                                                            .frame(width: expandedChart ? geo.size.width * 3 : geo.size.width * 1, height: UIScreen.screenHeight * 0.3)
                                                            .id("chart")
                                                            .onChange(of: expandedChart) { newValue in
                                                                // scroll to the latest data in chart after expanding
                                                                if newValue == true {
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                        withAnimation(.easeInOut(duration: 0.7)) {
                                                                            scroll.scrollTo("chart", anchor: .trailing)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                        // chart bg
                                        .background(Rectangle()
                                            .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light))
                                    }
                                }
                                .blur(radius: market.chartLoaded ? 0 : 3)
                                // progress view
                                if market.chartLoaded == false {
                                    ProgressView()
                                }
                            }
                            // picker
                            HStack {
                                Spacer()
                                Picker("Chart time interval", selection: $market.chartTimePicker) {
                                    ForEach(market.chartTimeIntervals, id: \.self) { interval in
                                        Text(interval)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: UIScreen.screenWidth * 0.7, height: 16)
                                .padding(.trailing)
                                
                                Button {
                                    withAnimation {
                                        expandedChart.toggle()
                                    }
                                } label: {
                                    Image(systemName: expandedChart ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                        .background(
                                            Circle()
                                                .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
                                                .frame(width: 32, height: 32)
                                        )
                                }
                                .padding(.trailing)
                            }
                            .offset(y: UIScreen.screenHeight * 0.15)
                        }
                        .frame(height: UIScreen.screenHeight * 0.3)
                    }
                    .padding(.vertical)
                    // MARK: Info
                    
                    HStack {
                        
                        // MARK: Image
                        if anyCoin.image != nil {
                            AsyncImage(
                                url: URL(string: anyCoin.image!),
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                },
                                placeholder: {
                                    Circle()
                                        .fill(colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                                        .frame(width: 40, height: 40)
                                        .opacity(blinkChange ? 0.3 : 1)
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                                blinkChange.toggle()
                                            }
                                        }
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
                        
                        // MARK: symbol
                        Text(anyCoin.symbol.uppercased())
                            .font(.system(size: 16))
                        
                        Spacer()
                        
                        // MARK: Price change
                        if let coin {
                            // Real data
                            
                            if market.chartTimePicker == "1D" { // MARK: 1D
                                if coin.marketData.priceChangePercentage24HInCurrency?[currency] != nil {
                                    // We have 1D data for price change %
                                    if coin.marketData.priceChangePercentage24HInCurrency![currency]! > 0 {
                                        // price change %
                                        Text("+\(coin.marketData.priceChangePercentage24HInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage24HInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("+\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else if coin.marketData.priceChangePercentage24HInCurrency![currency]! < 0 {
                                        Text("\(coin.marketData.priceChangePercentage24HInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage24HInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("-\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        Text("\(0.formatted(.currency(code: currency)))")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    }
                                    // We DONT have 1D data for price change %
                                } else {
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                    Spacer()
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                }
                            }
                            if market.chartTimePicker == "7D" { // MARK: 7D
                                if coin.marketData.priceChangePercentage7DInCurrency?[currency] != nil {
                                    // We have 7D data for price change %
                                    if coin.marketData.priceChangePercentage7DInCurrency![currency]! > 0 {
                                        // price change %
                                        Text("+\(coin.marketData.priceChangePercentage7DInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage7DInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("+\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else if coin.marketData.priceChangePercentage7DInCurrency![currency]! < 0 {
                                        Text("\(coin.marketData.priceChangePercentage7DInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage7DInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("-\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        Text("\(0.formatted(.currency(code: currency)))")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    }
                                    // We DONT have 7D data for price change %
                                } else {
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                    Spacer()
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                }
                            }
                            if market.chartTimePicker == "30D" { // MARK: 30D
                                if coin.marketData.priceChangePercentage30DInCurrency?[currency] != nil {
                                    // We have 30D data for price change %
                                    if coin.marketData.priceChangePercentage30DInCurrency![currency]! > 0 {
                                        // price change %
                                        Text("+\(coin.marketData.priceChangePercentage30DInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage30DInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("+\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else if coin.marketData.priceChangePercentage30DInCurrency![currency]! < 0 {
                                        Text("\(coin.marketData.priceChangePercentage30DInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage30DInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("-\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        Text("\(0.formatted(.currency(code: currency)))")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    }
                                    // We DONT have 30D data for price change %
                                } else {
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                    Spacer()
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                }
                            }
                            if market.chartTimePicker == "1Y" { // MARK: 1Y
                                if coin.marketData.priceChangePercentage1YInCurrency?[currency] != nil {
                                    // We have 1Y data for price change %
                                    if coin.marketData.priceChangePercentage1YInCurrency![currency]! > 0 {
                                        // price change %
                                        Text("+\(coin.marketData.priceChangePercentage1YInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage1YInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("+\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else if coin.marketData.priceChangePercentage1YInCurrency![currency]! < 0 {
                                        Text("\(coin.marketData.priceChangePercentage1YInCurrency![currency]!, specifier: "%.2f")%")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        // price change $
                                        let initialPrice: Double = coin.marketData.currentPrice[currency]! / (1 + (coin.marketData.priceChangePercentage1YInCurrency![currency]! / 100) )
                                        let priceChangeValue: Double = abs(initialPrice - coin.marketData.currentPrice[currency]!)
                                        Text("-\(priceChangeValue.formatted(.currency(code: currency)))")
                                            .foregroundColor(.red)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    } else {
                                        Text("0%")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                        Spacer()
                                        Text("\(0.formatted(.currency(code: currency)))")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 16))
                                            .opacity(blinkChange ? 0.3 : 1)
                                    }
                                    // We DONT have 1Y data for price change %
                                } else {
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                    Spacer()
                                    Text(market.noData)
                                        .fontWeight(.light)
                                        .font(.system(size: 16))
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .opacity(blinkChange ? 0.3 : 1)
                                }
                            }
                            if market.chartTimePicker == "All" { // MARK: All
                                 Spacer()
                            }
                        } else {
                            // Placeholder
                            (colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                                .frame(width: 70, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .opacity(blinkChange ? 0.3 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                        blinkChange.toggle()
                                    }
                                }
                            
                            Spacer()
                            
                            (colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                                .frame(width: 80, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .opacity(blinkChange ? 0.3 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                        blinkChange.toggle()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: UIScreen.screenWidth * 1)
                    
                    // MARK: Price
                    if let coin {
                        // Real data
                        // We have price data for given currency
                        if coin.marketData.currentPrice[currency] != nil {
                            Text("\(coin.marketData.currentPrice[currency]!.stringWithoutZeroFraction) $")
                                .font(.system(size: 20))
                                .opacity(blinkPrice ? 0.3 : 1)
                        // We DONT have price data for given currency
                        } else {
                            Text(market.noData)
                                .fontWeight(.light)
                                .font(.system(size: 20))
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Placeholder
                        (colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                            .frame(width: 100, height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(blinkChange ? 0.3 : 1)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    blinkChange.toggle()
                                }
                            }
                    }
                    Spacer()
                }
                .task {
                    do {
                        // fetch coin on appear
                        self.coin = try await market.fetchCoin(id: anyCoin.id)
                        // fetch chart on appear
                        chart = try await market.fetchCoinChart(coinID: anyCoin.id, interval: market.chartTimePicker)
                    } catch {
                        print("Failed to load \(anyCoin.id) detail info")
                    }
                }
                .onChange(of: market.chartTimePicker) { _ in
                    // animate interval change
                    market.chartLoaded = false
                    self.blinkChange = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.blinkChange = false
                        }
                    }
                    // fetch chart on time interval change
                    Task {
                        do {
                            chart = try await market.fetchCoinChart(coinID: anyCoin.id, interval: market.chartTimePicker)
                        } catch {
                            print("Failed to load chart for \(market.chartTimePicker)")
                        }
                    }
                }
                .onChange(of: coin?.marketData.currentPrice) { newPrice in
                    // animate price change
                    if market.oldMarketData?.currentPrice != newPrice {
                        blinkPrice = true
                        blinkChange = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                blinkPrice = false
                                blinkChange = false
                            }
                        }
                        // update chart on price change
                        Task {
                            do {
                                chart = try await market.fetchCoinChart(coinID: anyCoin.id, interval: market.chartTimePicker, isRefresh: true)
                            } catch {
                                print("Failed to load chart on ptice change for \(market.chartTimePicker)")
                            }
                        }
                    }
                }
                .onReceive(market.coinDetailTimer) { time in
                    Task {
                        do {
                            // update coin every 8 sec
                            self.coin = try await market.fetchCoin(id: anyCoin.id)
                        } catch {
                            print("Failed to update \(anyCoin.id) with time: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(anyCoin.name)
            }
        }
    }
}
