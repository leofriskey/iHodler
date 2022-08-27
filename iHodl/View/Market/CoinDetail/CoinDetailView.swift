//
//  CoinDetailView.swift
//  iHodl
//
//  Created by Leo Friskey on 20.08.2022.
//

import SwiftUI

struct CoinDetailView: View {
    
    //MARK: environments
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var market: Market
    
    //MARK: init
    let anyCoin: CryptoCurrency
    let currency = "usd"
    
    //MARK: coin & chart
    @State private var coin: Coin? = nil
    @State private var chart = [CoinChartData]()
    
    //MARK: animation
    @State private var blinkPrice = false
    @State private var blinkChange = false
    
    //MARK: expanded chart
    @State private var expandedChart = false
    
    //MARK: pricefinder
    @State private var priceFinderActivated = false
    
    //MARK: Market info
    @State private var marketInfoArray = [String]()
    
    
    var body: some View {
        ZStack {
            // MARK: Background
            (colorScheme == .dark ? LinearGradient.darkBG.ignoresSafeArea() : LinearGradient.lightBG.ignoresSafeArea())
            
            ScrollView {
                VStack {
                    
                    //MARK: PriceViewer Info
                    HStack {
                        if let currentActiveItem = market.currentActiveItem {
                            VStack(spacing: 5) {
                                // price
                                Text("\(currentActiveItem.price, specifier: "%.4f") $")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 18))
                                // date
                                Text(createDateTime(timestamp: currentActiveItem.date, interval: market.chartTimePicker))
                                    .foregroundColor(.secondary)
                                    .fontWeight(.light)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .frame(minHeight: 20)
                    
                    //MARK: Chart
                    ZStack {
                        ZStack {
                            //MARK: Chart
                            ZStack {
                                ZStack {
                                    if market.chartLoaded == true {
                                        GeometryReader { geo in
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                ScrollViewReader { scroll in
                                                    // MARK: chart
                                                    if coin != nil {
                                                        ChartView(coin: coin!, data: chart, interval: market.chartTimePicker, expanded: expandedChart, type: .real, showDetailPrice: priceFinderActivated)
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
                                            // MARK: chart bg
                                            .background(
                                                Rectangle()
                                                    .foregroundStyle(colorScheme == .dark ? LinearGradient.material02dark.shadow(.inner(color: priceFinderActivated ? Color.red : Color.black, radius: 10)) : LinearGradient.material02light.shadow(.inner(color: priceFinderActivated ? Color.red : Color.primary, radius: 10)))
                                            )
                                            // sticky Y Axis labels if expanded chart
                                            .overlay(
                                                expandedChart ?
                                                ChartView(coin: coin!, data: chart, interval: market.chartTimePicker, expanded: expandedChart, type: .overlayYAxis, showDetailPrice: false)
                                                    .frame(maxHeight: UIScreen.screenHeight * 0.229)
                                                    .padding(.horizontal, 5)
                                                    .padding(.bottom, 17)
                                                    .allowsHitTesting(false)
                                                :
                                                nil
                                            )
                                            // disable scrolling when priceFinder mode is on
                                            .environment(\.isScrollEnabled, priceFinderActivated ? false : true)
                                        }
                                    }
                                }
                                .blur(radius: market.chartLoaded ? 0 : 3)
                                // MARK: progress view
                                if market.chartLoaded == false {
                                    ProgressView()
                                }
                            }
                            // MARK: picker
                            HStack {
                                Spacer()
                                Picker("Chart time interval", selection: $market.chartTimePicker) {
                                    ForEach(market.chartTimeIntervals, id: \.self) { interval in
                                        Text(interval)
                                    }
                                }
                                .onChange(of: market.chartTimePicker) { _ in
                                    // MARK: animate time interval change
                                    market.chartLoaded = false
                                    self.blinkChange = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.blinkChange = false
                                        }
                                    }
                                    // MARK: fetch chart on time interval change
                                    Task {
                                        do {
                                            chart = try await market.fetchCoinChart(coinID: anyCoin.id, interval: market.chartTimePicker)
                                        } catch {
                                            print("Failed to load chart for \(market.chartTimePicker)")
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: UIScreen.screenWidth * 0.7, height: 16)
                                .padding(.trailing)
                                
                                Button {
                                    withAnimation {
                                        priceFinderActivated.toggle()
                                    }
                                } label: {
                                    Image(systemName: priceFinderActivated ? "xmark.square" : "dot.viewfinder")
                                        .foregroundColor(priceFinderActivated ? Color.red : Color.primary)
                                        .background(
                                            Circle()
                                                .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
                                                .frame(width: 32, height: 32)
                                        )
                                }
                                .padding(.trailing)
                                .shadow(radius: priceFinderActivated ? 1 : 0)
                                
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
                    .padding()
                    
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
                    
                    // Spacer
                    Color.clear
                        .frame(height: UIScreen.screenHeight * 0.04)
                    
                    //MARK: Market info
                    if let coin {
                        VStack(alignment: .leading) {
                            Text("Stats")
                                .font(.title3)
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    // Volume 1D
                                    InfoCardsView(coin: coin, type: .volume)
                                    // Market Cap
                                    InfoCardsView(coin: coin, type: .marketCap)
                                    // Circulating Supply
                                    InfoCardsView(coin: coin, type: .supply)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Spacer
                    Color.clear
                        .frame(height: UIScreen.screenHeight * 0.04)
                    
                    //MARK: Links
                    if let coin {
                        VStack(alignment: .leading) {
                            Text("Links")
                                .font(.title3)
                                .padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    if let websiteURL = coin.links?.homepage?[0] {
                                        LinkView(type: .website, url: websiteURL)
                                    }
                                    if let sourceCodeURL = coin.links?.reposURL?.github?[0] {
                                        LinkView(type: .sourcecode, url: sourceCodeURL)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    // Spacer
                    Color.clear
                        .frame(height: UIScreen.screenHeight * 0.1)
                }
                .task {
                    do {
                        //MARK: fetch coin on appear
                        self.coin = try await market.fetchCoin(id: anyCoin.id)
                        
                        
                        //MARK: fetch chart on appear
                        chart = try await market.fetchCoinChart(coinID: anyCoin.id, interval: market.chartTimePicker)
                    } catch {
                        print("Failed to load \(anyCoin.id) detail info")
                    }
                }
                .onChange(of: coin?.marketData.currentPrice) { newPrice in
                    // MARK: animate price change
                    if market.oldMarketData?.currentPrice != newPrice {
                        blinkPrice = true
                        blinkChange = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                blinkPrice = false
                                blinkChange = false
                            }
                        }
                        // MARK: update chart on price change
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
                    guard market.coinDetailTimerIsActive else { return }
                    
                    Task {
                        do {
                            // MARK: update coin every 30 sec
                            self.coin = try await market.fetchCoin(id: anyCoin.id)
                        } catch {
                            print("Failed to update \(anyCoin.id) with time: \(error.localizedDescription)")
                        }
                    }
                }
                .onAppear {
                    market.coinDetailTimerIsActive = true
                }
                .onDisappear {
                    market.coinDetailTimerIsActive = false
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(anyCoin.name)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    //MARK: Add/Remove from Watchlist
                    Button {
                        if self.coin != nil {
                            if !market.watchlist.contains(where: { $0.id == coin!.id } ) {
                                let previewCoin = market.coinToCoinPreview(coin!)
                                market.addToWatchlist(previewCoin)
                            } else {
                                market.removeFromWatchlist(coin!)
                            }
                        }
                    } label: {
                        Image(systemName: market.watchlist.contains(where: { $0.id == coin?.id } ) ? "star.slash.fill" : "star")
                            .font(.system(size: 14))
                    }
                }
            }
        }
    }
}
