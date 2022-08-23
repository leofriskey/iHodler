//
//  Market.swift
//  iHodl
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI

@MainActor class Market: ObservableObject {
    
    let coinsTimer = Timer.publish(every: 20, tolerance: 0.5, on: .main, in: .common).autoconnect()
    let coinDetailTimer = Timer.publish(every: 8, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    // MARK: Lang
    let title = "Market"
    let top10Title = "Top 10"
    let watchlistTitle = "Watchlist"
    let watchlistAbout = "Add coins to watchlist by holding on them"
    let noData = "no data"
    
    // MARK: Global chart
    @Published private(set) var globalData: GlobalData? = nil
    @Published var gcPicker = "Overview"
    let gcValues = ["Overview"]
    
    // MARK: Watchlist
    @AppStorage("watchlist") private(set) var watchlist = WatchlistCoins()
    
    // MARK: Top 10 Coins
    @Published private(set) var top10Coins = [CoinPreview]()
    
    // MARK: Search
    @Published var searchText = ""
    @Published var searchLengthIsEnough = false
    @Published var searchedCoins = [SearchedCoin]()
    @Published var searchNotFound = false
    
    // MARK: Time Interval
    @AppStorage("time_interval") var timeInterval = "1D"
    let timeIntervals = ["1D", "7D"]
    
    // MARK: API Errors
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
                return "Try again in a minute"
            case .failedAddingToWatchlist:
                return "Check your internet connection"
            }
        }
    }
    @Published var error: Error? = nil
    
    // MARK: DetailView
    @AppStorage("chartTimePicker") var chartTimePicker = "1D"
    let chartTimeIntervals = ["1H","1D","7D","30D","1Y", "All"]
    @Published var oldMarketData: Coin.MarketData? = nil
    
    
    // MARK: Fetch Coin
    func fetchCoin(id: String, forPreview: Bool = false) async throws -> Coin? {
        // for preview (e.g. watchlist)
        if forPreview {
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=true") else { return nil}
            
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration)
            
            let (data, response) = try await session.data(from: url)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            let decodedResponse = try JSONDecoder().decode(Coin.self, from: data)
            
            return decodedResponse

        // full info (e.g. detail view)
        } else {
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(id)?localization=false&tickers=true&market_data=true&community_data=true&developer_data=true&sparkline=false") else { return nil }
            
            let configuration = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configuration)
            
            let (data, response) = try await session.data(from: url)
            
            if (response as? HTTPURLResponse)?.statusCode == 429 {
                error = .limitHit
                throw Error.limitHit
            }
            
            let decodedResponse = try JSONDecoder().decode(Coin.self, from: data)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//                self.oldMarketData = decodedResponse.marketData
//            }
            
            return decodedResponse
        }
    }
    
    func setPlaceholderTop10() {
        top10Coins = Array(repeating: CoinPreview.placeholder, count: 10)
    }
    
    // MARK: fetch Top 10
    func fetchTop10Coins() async throws {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=1h%2C24h%2C7d%2C30d%2C1y") else { return }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: url)
        
        if (response as? HTTPURLResponse)?.statusCode == 429 {
            error = .limitHit
            throw Error.limitHit
        }
        
        if let decodedResponse = try? JSONDecoder().decode([CoinPreview].self, from: data) {
            top10Coins = decodedResponse
        }
        syncTop10andWatchlist()
    }
    
    // MARK: sync Top 10 & Watchlist
    func syncTop10andWatchlist() { // i think this logic is flawed
        for i in top10Coins {
            if let index = watchlist.firstIndex(where: { $0.id == i.id }) {
                withAnimation {
                    watchlist[index] = i
                }
            }
        }
    }
    
    // MARK: fetch Watchlist
    func fetchWatchlist() async throws {
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
                        withAnimation {
                            watchlist[index] = coinForPreview
                        }
                    }
                }
            }
        }
    }
    
    // MARK: add to watchlist
    
    // add to watchlist from top 10 (CoinPreview -> CoinPreview)
    func addToWatchlistFromTop10(_ coin: CoinPreview) {
        if watchlist.contains(where: { $0.id == coin.id } ) {
            return
        } else {
            watchlist.append(coin)
        }
    }
    
    // add placeholder to watchlist while coin is fetching
    func addToWatchlistFromSearchPlaceHolder() {
        let coin = CoinPreview.placeholder
        
        if watchlist.contains(where: { $0.id == coin.id } ) {
            return
        } else {
            watchlist.append(coin)
        }
    }
    
    // fetch coin, transform it for preview and replace placeholder with it
    func addToWatchListFromSearch(id: String) async throws {
        do {
            let coin = try await fetchCoin(id: id, forPreview: true)
            
            if let coin = coin {
                let coinForPreview = coinToCoinPreview(coin)
                if watchlist.contains(where: { $0.id == coinForPreview.id } ) {
                    return
                } else {
                    if let index = watchlist.firstIndex(where: { $0.symbol == "placeholder" }) {
                        withAnimation {
                            watchlist[index] = coinForPreview
                        }
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
    
    // MARK: transform Coin to Coin_Preview
    func coinToCoinPreview(_ coin: Coin, currency: String = "usd") -> CoinPreview {
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
    
    
    // MARK: remove from watchlist
    func removeFromWatchlist<T: Identifiable>(_ coin: T) {
        if watchlist.contains(where: { $0.id == coin.id as! String } ) {
            watchlist.removeAll { $0.id == coin.id as! String }
        } else {
            return
        }
    }
    
    // MARK: Search for coins
    @MainActor func searchForCoins(_ word: String, currency: String = "usd") async {
        
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
        
    // add filtered coins to output property for feeding views
        withAnimation {
            self.searchedCoins = searchedCoinsWithPrice.filter { $0.id.range(of: query, options: .caseInsensitive) != nil || $0.name.range(of: query, options: .caseInsensitive) != nil || $0.symbol.range(of: query, options: .caseInsensitive) != nil }
        }
    }
    
    // MARK: Fetch Global data
    func fetchGlobal() async throws {
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
    
    func getScaleEffect(index: Int) -> Double {
        let symbol = top10Coins[index].symbol
        let rawPercentage = globalData?.data.marketCapPercentage[symbol]
        let percentage = ((rawPercentage ?? 0) / 100) + 1
        
        return percentage
    }
    
    init() {
        // set placeholder for top10 before coins are fetched from the api
        setPlaceholderTop10()
        Task {
            do {
                // fetch data on launch
                try await fetchWatchlist()
                try await fetchTop10Coins()
                try await fetchGlobal()
            } catch {
                print("Failed to fetch data on launch: \(error.localizedDescription)")
            }
        }
    }
}
