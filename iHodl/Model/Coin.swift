//
//  Coin.swift
//  iHodl
//
//  Created by Leo Friskey on 04.08.2022.
//

import Foundation

protocol CryptoCurrency {
    var id: String { get }
    var symbol: String { get }
    var name: String { get }
    var image: String? { get }
}

// MARK: - Coin
struct Coin: Identifiable, Codable {
    let id, symbol, name: String
    let assetPlatformID: String?
    let platforms: Platforms?
    let blockTimeInMinutes: Int?
    let hashingAlgorithm: String?
    let categories: [String]?
    let coinDescription: Description?
    let links: Links?
    let image: ImageSize?
    let countryOrigin, genesisDate: String?
    let sentimentVotesUpPercentage, sentimentVotesDownPercentage: Double?
    let marketCapRank, coingeckoRank: Int?
    let coingeckoScore, developerScore, communityScore, liquidityScore: Double?
    let publicInterestScore: Double?
    let marketData: MarketData
    let lastUpdated: String?
    let tickers: [Ticker]?
    
    // MARK: - Platforms
    struct Platforms: Codable {
        let empty: String?

        enum CodingKeys: String, CodingKey {
            case empty = ""
        }
    }
    
    // MARK: - Description
    struct Description: Codable {
        let en: String?
    }
    
    // MARK: - Links
    struct Links: Codable {
        let homepage: [String]?
        let blockchainSite, officialForumURL: [String]?
        let chatURL, announcementURL: [String]?
        let twitterScreenName: String?
        let facebookUsername: String?
        let telegramChannelIdentifier: String?
        let subredditURL: String?
        let reposURL: ReposURL?
        
        // MARK: - ReposURL
        struct ReposURL: Codable {
            let github: [String]?
            let bitbucket: [String]?
        }

        enum CodingKeys: String, CodingKey {
            case homepage
            case blockchainSite = "blockchain_site"
            case officialForumURL = "official_forum_url"
            case chatURL = "chat_url"
            case announcementURL = "announcement_url"
            case twitterScreenName = "twitter_screen_name"
            case facebookUsername = "facebook_username"
            case telegramChannelIdentifier = "telegram_channel_identifier"
            case subredditURL = "subreddit_url"
            case reposURL = "repos_url"
        }
    }
    
    // MARK: - ImageSize
    struct ImageSize: Codable {
        let thumb, small, large: String?
    }
    
    // MARK: - MarketData
    struct MarketData: Codable {
        let currentPrice: [String: Double]
        let ath, athChangePercentage: [String: Double]?
        let athDate: [String: String]?
        let atl, atlChangePercentage: [String: Double]?
        let atlDate: [String: String]?
        let marketCap: [String: Double]?
        let marketCapRank: Int?
        let fullyDilutedValuation, totalVolume, high24H, low24H: [String: Double]?
        let priceChange24H, priceChangePercentage24H, priceChangePercentage7D, priceChangePercentage14D: Double?
        let priceChangePercentage30D, priceChangePercentage60D, priceChangePercentage200D, priceChangePercentage1Y: Double?
        let marketCapChange24H, marketCapChangePercentage24H: Double?
        let priceChange24HInCurrency, priceChangePercentage1HInCurrency, priceChangePercentage24HInCurrency, priceChangePercentage7DInCurrency: [String: Double]?
        let priceChangePercentage14DInCurrency, priceChangePercentage30DInCurrency, priceChangePercentage60DInCurrency, priceChangePercentage200DInCurrency: [String: Double]?
        let priceChangePercentage1YInCurrency, marketCapChange24HInCurrency, marketCapChangePercentage24HInCurrency: [String: Double]?
        let totalSupply, maxSupply, circulatingSupply: Double?
        let sparkline7D: Sparkline7D?
        let lastUpdated: String?

        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case ath
            case athChangePercentage = "ath_change_percentage"
            case athDate = "ath_date"
            case atl
            case atlChangePercentage = "atl_change_percentage"
            case atlDate = "atl_date"
            case marketCap = "market_cap"
            case marketCapRank = "market_cap_rank"
            case fullyDilutedValuation = "fully_diluted_valuation"
            case totalVolume = "total_volume"
            case high24H = "high_24h"
            case low24H = "low_24h"
            case priceChange24H = "price_change_24h"
            case priceChangePercentage24H = "price_change_percentage_24h"
            case priceChangePercentage7D = "price_change_percentage_7d"
            case priceChangePercentage14D = "price_change_percentage_14d"
            case priceChangePercentage30D = "price_change_percentage_30d"
            case priceChangePercentage60D = "price_change_percentage_60d"
            case priceChangePercentage200D = "price_change_percentage_200d"
            case priceChangePercentage1Y = "price_change_percentage_1y"
            case marketCapChange24H = "market_cap_change_24h"
            case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
            case priceChange24HInCurrency = "price_change_24h_in_currency"
            case priceChangePercentage1HInCurrency = "price_change_percentage_1h_in_currency"
            case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
            case priceChangePercentage7DInCurrency = "price_change_percentage_7d_in_currency"
            case priceChangePercentage14DInCurrency = "price_change_percentage_14d_in_currency"
            case priceChangePercentage30DInCurrency = "price_change_percentage_30d_in_currency"
            case priceChangePercentage60DInCurrency = "price_change_percentage_60d_in_currency"
            case priceChangePercentage200DInCurrency = "price_change_percentage_200d_in_currency"
            case priceChangePercentage1YInCurrency = "price_change_percentage_1y_in_currency"
            case marketCapChange24HInCurrency = "market_cap_change_24h_in_currency"
            case marketCapChangePercentage24HInCurrency = "market_cap_change_percentage_24h_in_currency"
            case totalSupply = "total_supply"
            case maxSupply = "max_supply"
            case circulatingSupply = "circulating_supply"
            case sparkline7D = "sparkline_7d"
            case lastUpdated = "last_updated"
        }
    }
    
    // MARK: - Ticker
    struct Ticker: Codable {
        let base: String?
        let target: String?
        let market: Market?
        let last, volume: Double?
        let convertedLast, convertedVolume: [String: Double]?
        let bidAskSpreadPercentage: Double?
        let timestamp, lastTradedAt, lastFetchAt: String?
        let isAnomaly, isStale: Bool?
        let tradeURL: String?
        let coinID: String?
        let targetCoinID: String?
        
        // MARK: - Market
        struct Market: Codable {
            let name, identifier: String?
            let hasTradingIncentive: Bool?

            enum CodingKeys: String, CodingKey {
                case name, identifier
                case hasTradingIncentive = "has_trading_incentive"
            }
        }

        enum CodingKeys: String, CodingKey {
            case base, target, market, last, volume
            case convertedLast = "converted_last"
            case convertedVolume = "converted_volume"
            case bidAskSpreadPercentage = "bid_ask_spread_percentage"
            case timestamp
            case lastTradedAt = "last_traded_at"
            case lastFetchAt = "last_fetch_at"
            case isAnomaly = "is_anomaly"
            case isStale = "is_stale"
            case tradeURL = "trade_url"
            case coinID = "coin_id"
            case targetCoinID = "target_coin_id"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case assetPlatformID = "asset_platform_id"
        case platforms
        case blockTimeInMinutes = "block_time_in_minutes"
        case hashingAlgorithm = "hashing_algorithm"
        case categories
        case coinDescription = "description"
        case links, image
        case countryOrigin = "country_origin"
        case genesisDate = "genesis_date"
        case sentimentVotesUpPercentage = "sentiment_votes_up_percentage"
        case sentimentVotesDownPercentage = "sentiment_votes_down_percentage"
        case marketCapRank = "market_cap_rank"
        case coingeckoRank = "coingecko_rank"
        case coingeckoScore = "coingecko_score"
        case developerScore = "developer_score"
        case communityScore = "community_score"
        case liquidityScore = "liquidity_score"
        case publicInterestScore = "public_interest_score"
        case marketData = "market_data"
        case lastUpdated = "last_updated"
        case tickers
    }
}

// MARK: - Sparkline7D
struct Sparkline7D: Codable {
    let price: [Double]?
}

// MARK: - CoinPreview
struct CoinPreview: Identifiable, Codable, CryptoCurrency {
    
    static let placeholder = CoinPreview(id: UUID().uuidString , symbol: "placeholder", name: "placeholder", image: nil, currentPrice: 0, marketCapRank: nil, priceChange24H: nil, marketCapChangePercentage24H: nil, lastUpdated: nil, sparkline7D: Sparkline7D(price: Array(repeating: 0.00, count: 24)), priceChangePercentage1HInCurrency: nil, priceChangePercentage1YInCurrency: nil, priceChangePercentage24HInCurrency: nil, priceChangePercentage30DInCurrency: nil, priceChangePercentage7DInCurrency: nil)
    
    let id, symbol, name: String
    let image: String?
    let currentPrice: Double
    let marketCapRank: Int?
    let priceChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let lastUpdated: String?
    
    let sparkline7D: Sparkline7D
    
    let priceChangePercentage1HInCurrency: Double?
    let priceChangePercentage1YInCurrency: Double?
    let priceChangePercentage24HInCurrency: Double?
    let priceChangePercentage30DInCurrency: Double?
    let priceChangePercentage7DInCurrency: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name
        case image
        case currentPrice = "current_price"
        case marketCapRank = "market_cap_rank"
        case priceChange24H = "price_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case lastUpdated = "last_updated"
        case sparkline7D = "sparkline_in_7d"
        case priceChangePercentage1HInCurrency = "price_change_percentage_1h_in_currency"
        case priceChangePercentage1YInCurrency = "price_change_percentage_1y_in_currency"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
        case priceChangePercentage30DInCurrency = "price_change_percentage_30d_in_currency"
        case priceChangePercentage7DInCurrency = "price_change_percentage_7d_in_currency"
    }
}
// MARK: Watchlist Coins App Storage
typealias WatchlistCoins = [CoinPreview]
extension WatchlistCoins: RawRepresentable {
    public init?(rawValue: String) {
            guard let data = rawValue.data(using: .utf8),
                let result = try? JSONDecoder().decode(WatchlistCoins.self, from: data)
            else {
                return nil
            }
            self = result
        }

        public var rawValue: String {
            guard let data = try? JSONEncoder().encode(self),
                let result = String(data: data, encoding: .utf8)
            else {
                return "[]"
            }
            return result
        }
}

// MARK: Search Coins

// searched coin without price
struct CoinNoPrice: Identifiable, Decodable {
    
    let id, symbol, name: String
    let marketCapRank: Int?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, marketCapRank = "market_cap_rank", image = "large"
    }
}

// array of searched coins without prices
struct SearchedCoinsNoPrice: Decodable {
    let coins: [CoinNoPrice]
}

// final searched coin with price
struct SearchedCoin: Identifiable, CryptoCurrency {
    let id, symbol, name: String
    let marketCapRank: Int?
    let image: String?
    let currentPrice: Double
}


// MARK: - Global
struct GlobalData: Codable {
    let data: DataClass
    
    // MARK: - DataClass
    struct DataClass: Codable {
        let activeCryptocurrencies: Int?
        let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
        let marketCapChangePercentage24HUsd: Double

        enum CodingKeys: String, CodingKey {
            case activeCryptocurrencies = "active_cryptocurrencies"
            case totalMarketCap = "total_market_cap"
            case totalVolume = "total_volume"
            case marketCapPercentage = "market_cap_percentage"
            case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
        }
    }
}

// MARK: CoinChart
struct CoinChart: Decodable {
    let prices: [[Double]]
}

// create CoinChartData dot from CoinChart
struct CoinChartData: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}
