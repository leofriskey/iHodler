//
//  Market.swift
//  iHodler
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI
import Combine

@MainActor final class Market: ObservableObject {
    
    //MARK: Timers
    // Market View timer
    let marketTimer = Timer.publish(every: 30, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @Published var marketTimerIsActive = true
    // Coin Detail View timer
    let coinDetailTimer = Timer.publish(every: 30, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @Published var coinDetailTimerIsActive = false
    
    //MARK: Currency
    @Published private(set) var currency = "usd"
    
    // subscribe to currency changes from settings
    @AppStorage("settingsCurrency") private var settingsCurrency = "usd"
    private(set) var cancellable: AnyCancellable?
    func connect(_ publisher: AnyPublisher<String,Never>) {
            cancellable = publisher.sink(receiveValue: { currency in
                self.settingsCurrency = currency
            })
        }
    
    //MARK: Global chart
    @Published private(set) var globalData: GlobalData? = nil
    @Published var gcPicker = "Overview"
    let gcValues = ["Overview"]
    
    
    //MARK: Watchlist
    @AppStorage("watchlist") private(set) var watchlist = WatchlistCoins()
    
    
    //MARK: Top 10 Coins
    @Published private(set) var top10Coins = [CoinPreview]()
    
    //MARK: Search
    @Published var searchText = ""
    @Published private(set) var searchLengthIsEnough = false
    @Published private(set) var searchedCoins = [SearchedCoin]()
    @Published private(set) var searchNotFound = false
    
    func validateSearch() async {
        // check if search text length is >= 3
        if searchText.count >= 3 {
            searchLengthIsEnough = true
            searchNotFound = false
            
            // fetch searched coins
            await searchForCoins(searchText)
            
        } else {
            searchLengthIsEnough = false
        }
    }
    func deleteCachedSearch() {
        searchLengthIsEnough = false
        searchedCoins = []
    }
    
    //MARK: Time Interval
    @AppStorage("time_interval") var marketInterval = "7D"
    let marketIntervals = ["1D", "7D"]
    
    //MARK: API Errors
    enum Error: LocalizedError {
        case limitHit, failedAddingToWatchlist
        
        var errorDescription: String? {
            switch self {
            case .limitHit:
                return "Too many requests"
            case .failedAddingToWatchlist:
                return "Could not add coin to a watchlist"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .limitHit:
                return "Try again in a few minutes."
            case .failedAddingToWatchlist:
                return "Check your internet connection"
            }
        }
    }
    @Published var error: Error? = nil
    @Published var errorTime = 120
    let errorTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let sleeptime: UInt64 = 120_000_000_000
    
    func reduceErrorTime() {
        guard error != nil else { return }
        
        if errorTime > 0 {
            errorTime -= 1
        }
    }
    
    //MARK: DetailView
    @AppStorage("chartTimePicker") var chartTimePicker = "7D"
    let chartTimeIntervals = ["1D","7D","30D","1Y","All"]
    @Published var oldMarketData: Coin.MarketData? = nil
    
    //MARK: Chart
    @Published var currentActiveItem: CoinChartData? = nil
    
    
    //MARK: Fetch Coin
    func fetchCoin(id: String, forPreview: Bool = false) async throws -> Coin? {
        // get user's chosen currency from settings
        let currency = settingsCurrency
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        // for preview (e.g. watchlist)
        if forPreview {
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)?localization=fasle&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=true") else { return nil}
            
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration)
            
            let (data, response) = try await session.data(from: url)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            let decodedResponse = try JSONDecoder().decode(Coin.self, from: data)
            
            self.currency = currency
            
            return decodedResponse

        // full info (e.g. detail view)
        } else {
            // get user's chosen currency from settings
            let currency = settingsCurrency
            
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=true&market_data=true&community_data=true&developer_data=true&sparkline=true") else { return nil }
            
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration)
            
            let (data, response) = try await session.data(from: url)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            let decodedResponse = try JSONDecoder().decode(Coin.self, from: data)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.oldMarketData = decodedResponse.marketData
            }
            
            self.currency = currency
            
            return decodedResponse
        }
    }
    
    //MARK: set placeholder top 10
    func setPlaceholderTop10() {
        for _ in 0...10 {
            top10Coins.append(CoinPreview(id: UUID().uuidString , symbol: "placeholder", name: "placeholder", image: nil, currentPrice: 0, marketCapRank: nil, priceChange24H: nil, marketCapChangePercentage24H: nil, lastUpdated: nil, sparkline7D: Sparkline7D(price: Array(repeating: 0.00, count: 24)), priceChangePercentage1HInCurrency: nil, priceChangePercentage1YInCurrency: nil, priceChangePercentage24HInCurrency: nil, priceChangePercentage30DInCurrency: nil, priceChangePercentage7DInCurrency: nil))
        }
    }
    
    //MARK: fetch Top 10
    func fetchTop10Coins() async throws {
        
        // get user's chosen currency from settings
        let currency = settingsCurrency
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=1h%2C24h%2C7d%2C30d%2C1y") else { return }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            error = .limitHit
            throw Error.limitHit
        }
        
        let decodedResponse = try JSONDecoder().decode([CoinPreview].self, from: data)
        
        self.currency = currency
        top10Coins = decodedResponse
        
        syncTop10andWatchlist()
    }
    
    //MARK: sync Top 10 & Watchlist
    private func syncTop10andWatchlist() {
        for i in top10Coins {
            if let index = watchlist.firstIndex(where: { $0.id == i.id }) {
                watchlist[index] = i
            }
        }
    }
    
    //MARK: fetch Watchlist
    func fetchWatchlist() async throws {
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        for i in watchlist {
            // only fetch those that are not in (synced with) top 10
            if top10Coins.firstIndex(where: { $0.id == i.id } ) != nil {
                continue
            } else {
                // fetch Coin
                let coin = try await fetchCoin(id: i.id, forPreview: true)
                
                if let coin = coin {
                    // transform to CoinPreview
                    let coinForPreview = coinToCoinPreview(coin)
                    
                    // update CoinPreview in a watchlist
                    if let index = watchlist.firstIndex(where: { $0.id == coinForPreview.id }) {
                        watchlist[index] = coinForPreview
                    }
                }
            }
        }
    }
    
    //MARK: add to watchlist
    func addToWatchlist(_ coin: CoinPreview) {
        if watchlist.contains(where: { $0.id == coin.id } ) {
            return
        } else {
            watchlist.append(coin)
        }
    }
    
    //MARK: add placeholder to watchlist while coin is fetching
    func addToWatchlistFromSearchPlaceHolder() {
        let coin = CoinPreview.placeholder
        
        if watchlist.contains(where: { $0.id == coin.id } ) {
            return
        } else {
            watchlist.append(coin)
        }
    }
    
    //MARK: fetch coin, transform it for preview and replace placeholder with it
    func addToWatchListFromSearch(id: String) async throws {
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        do {
            let coin = try await fetchCoin(id: id, forPreview: true)
            
            if let coin = coin {
                let coinForPreview = coinToCoinPreview(coin)
                if watchlist.contains(where: { $0.id == coinForPreview.id } ) {
                    return
                } else {
                    if let index = watchlist.firstIndex(where: { $0.symbol == "placeholder" }) {
                        watchlist[index] = coinForPreview
                    }
                }
            }
        } catch {
            self.error = .failedAddingToWatchlist
            if let index = watchlist.firstIndex(where: { $0.symbol == "placeholder"}) {
                watchlist.remove(at: index)
            }
            throw Error.failedAddingToWatchlist
        }
    }
    
    //MARK: remove from watchlist
    func removeFromWatchlist<T: Identifiable>(_ coin: T) {
        if watchlist.contains(where: { $0.id == coin.id as! String } ) {
            watchlist.removeAll { $0.id == coin.id as! String }
        } else {
            return
        }
    }
    
    //MARK: transform Coin to Coin_Preview
    func coinToCoinPreview(_ coin: Coin) -> CoinPreview {
        
        // get user's chosen currency from settings
        let currency = settingsCurrency
        
        return CoinPreview(
            id: coin.id,
            symbol: coin.symbol,
            name: coin.name,
            image: coin.image?.large,
            currentPrice: coin.marketData.currentPrice["\(currency)"] ?? 0,
            marketCapRank: coin.marketCapRank,
            priceChange24H: coin.marketData.priceChangePercentage24HInCurrency?["\(currency)"],
            marketCapChangePercentage24H: coin.marketData.marketCapChangePercentage24H,
            lastUpdated: coin.marketData.lastUpdated,
            sparkline7D: coin.marketData.sparkline7D ?? Sparkline7D(price: Array(repeating: 0.00, count: 24)),
            priceChangePercentage1HInCurrency: coin.marketData.priceChangePercentage1HInCurrency?["\(currency)"],
            priceChangePercentage1YInCurrency: coin.marketData.priceChangePercentage1YInCurrency?["\(currency)"],
            priceChangePercentage24HInCurrency: coin.marketData.priceChangePercentage24HInCurrency?["\(currency)"],
            priceChangePercentage30DInCurrency: coin.marketData.priceChangePercentage30DInCurrency?["\(currency)"],
            priceChangePercentage7DInCurrency: coin.marketData.priceChangePercentage7DInCurrency?["\(currency)"])
    }
    
    //MARK: Search for coins
    @MainActor func searchForCoins(_ word: String) async {
        
        // get user's chosen currency from settings
        let currency = settingsCurrency
        
        if self.error != nil {
            do {
                try await Task.sleep(nanoseconds: self.sleeptime)
            } catch {
                print("Failed to make search sleep while limit hit API")
            }
        }
        
        let query = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var searchedCoinsNoPrice = [CoinNoPrice]()
        var priceQuery = ""
        var searchedPrices = [String: [String: Double]]()
        var searchedCoinsWithPrice = [SearchedCoin]()
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        
    // search coins without price
        // url
        guard let searchUrl = URL(string: "https://api.coingecko.com/api/v3/search?query=\(query)") else {
            print("Invalid search query url")
            return
        }
        
        do {
            // fetch searched coins from api
            let (searchData, response) = try await session.data(from: searchUrl)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            // decode searched coins
            let decodedResponse = try JSONDecoder().decode(SearchedCoinsNoPrice.self, from: searchData)
            
            for coin in decodedResponse.coins {
                // add searched coins without price to array
                searchedCoinsNoPrice.append(coin)
                // build price query for 2nd api call
                priceQuery += ("\(coin.id),")
            }
            
            if searchedCoinsNoPrice.isEmpty {
                withAnimation {
                    self.searchNotFound = true
                }
            }
        } catch {
            print(String(describing: error))
        }
        
        
    // search prices for given coins
        //url
        guard let priceUrl = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=\(priceQuery)&vs_currencies=\(currency)") else {
            print("Invalid price query url")
            return
        }
        
        do {
            // fetch searched coins' prices from api
            let (priceData, response) = try await session.data(from: priceUrl)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            // decode prices
            let decodedPrices = try JSONDecoder().decode([String: [String: Double]].self, from: priceData)
            // add to temp dictionary
            searchedPrices = decodedPrices
        } catch {
            print(String(describing: error))
        }
        
    // map coins with prices
        for coin in searchedCoinsNoPrice {
            if searchedPrices["\(coin.id)"] != nil {
                searchedCoinsWithPrice.append(SearchedCoin(id: coin.id, symbol: coin.symbol, name: coin.name, marketCapRank: coin.marketCapRank ?? 0, image: coin.image, currentPrice: (searchedPrices[coin.id]?[currency]) ?? 0))
            } else {
                print("Could not find a match in price query and search query")
            }
        }
        
    // add filtered coins to output property for feeding views (+ update currency)
        self.currency = currency
        withAnimation {
            self.searchedCoins = searchedCoinsWithPrice.filter { $0.id.range(of: query, options: .caseInsensitive) != nil || $0.name.range(of: query, options: .caseInsensitive) != nil || $0.symbol.range(of: query, options: .caseInsensitive) != nil }
        }
    }
    
    //MARK: Fetch Global data
    func fetchGlobal() async throws {
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else {
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            error = .limitHit
            throw Error.limitHit
        }
        
        let decodedResponse = try JSONDecoder().decode(GlobalData.self, from: data)
        withAnimation {
            self.globalData = decodedResponse
        }
    }
    
    //MARK: get scale effect
    func getScaleEffect(index: Int) -> Double {
        let symbol = top10Coins[index].symbol
        let rawPercentage = globalData?.data.marketCapPercentage[symbol]
        let percentage = ((rawPercentage ?? 0) / 100) + 1
        
        return percentage
    }
    
    //MARK: Fetch Coin Chart
    func fetchCoinChart(coinID: String, interval: String, isRefresh: Bool = false) async throws -> [CoinChartData] {
        
        // get user's chosen currency from settings
        let currency = settingsCurrency
        
        if self.error != nil {
            try await Task.sleep(nanoseconds: self.sleeptime)
        }
        
        var tempUrl: URL? = nil
        
        if interval == "1D" {
            tempUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(currency)&days=1")
        }
        if interval == "7D" {
            tempUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(currency)&days=7")
        }
        if interval == "30D" {
            tempUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(currency)&days=30")
        }
        if interval == "1Y" {
            tempUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(currency)&days=365")
        }
        if interval == "All" {
            tempUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(currency)&days=max&interval=monthly")
        }
        
        guard let url = tempUrl else { return [CoinChartData]() }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            error = .limitHit
            throw Error.limitHit
        }
        
        let decodedResponse = try JSONDecoder().decode(CoinChart.self, from: data)
        
        var tempArray = [CoinChartData]()
        
        for datePrice in decodedResponse.prices {
            tempArray.append(CoinChartData(date: Date(timeIntervalSince1970: (datePrice[0] / 1000.0)), price: datePrice[1]))
        }
        
        if interval == "1D" {
            tempArray = tempArray.enumerated().compactMap { index, element in index % 12 == 0 ? element : nil }
        }
        
        
        if interval == "All" {
            tempArray = tempArray.enumerated().compactMap { index, element in index % 7 == 0 ? element : nil }
        }
        
        self.currency = currency
        return tempArray
    }
    
    
    //MARK: Init
    init() {
        // set placeholder for top10 before coins are fetched from the api
        setPlaceholderTop10()
        Task {
            do {
                // fetch data on launch
                try await fetchTop10Coins()
                try await fetchWatchlist()
                try await fetchGlobal()
            } catch {
                print("Failed to fetch data on launch: \(error.localizedDescription)")
            }
        }
    }
}
