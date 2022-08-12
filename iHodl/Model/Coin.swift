//
//  Coin.swift
//  iHodl
//
//  Created by Leo Friskey on 04.08.2022.
//

import Foundation

struct Coin: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    var description: [String: String]
    var links: [String: String]
    var image: [String: String]
    var sentiment_votes_up_percentage: Double
    var sentiment_votes_down_percentage: Double
    var market_cap_rank: Int
    
    struct MarketData: Codable {
        var current_price: [String: Double]
        /// ath/atl, volume, market cap
        var ath: [String: Double]
        var ath_change_percentage: [String: Double]
        var ath_date: [String: Double]
        var atl: [String: Double]
        var atl_change_percentage: [String: Double]
        var atl_date: [String: String]
        var market_cap: [String: Double]
        var fully_diluted_valuation: [String: Double]
        var total_volume: [String: Double]
        /// high & low 24h
        var high_24h: [String: Double]
        var low_24h: [String: Double]
        /// price change
        var price_change_24h: Double
        var price_change_percentage_24h: Double
        var price_change_percentage_7d: Double
        var price_change_percentage_30d: Double
        var price_change_percentage_200d: Double
        var price_change_percentage_1y: Double
        var market_cap_change_24h: Double
        var price_change_24h_in_currency: [String: Double]
        var price_change_percentage_1h_in_currency: [String: Double]
        var price_change_percentage_24h_in_currency: [String: Double]
        var price_change_percentage_7d_in_currency: [String: Double]
        var price_change_percentage_200d_in_currency: [String: Double]
        var price_change_percentage_1y_in_currency: [String: Double]
        var market_cap_change_24h_in_currency: [String: Double]
        var market_cap_change_percentage_24h_in_currency: [String: Double]
        var total_supply: Int
        var max_supply: Int
        var circulating_supply: Int
        var sparkline_7d: [String: Double]
        var last_updated: String
    }
    var market_data: MarketData
    
}

struct Coin_Preview: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let market_cap_rank: Int
    let price_change_24h: Double
    let last_updated: String
    
    struct Sparkline: Codable {
        let price: [Double]
    }
    let sparkline_in_7d: Sparkline
    
    let price_change_percentage_1h_in_currency: Double
    let price_change_percentage_1y_in_currency: Double
    let price_change_percentage_24h_in_currency: Double
    let price_change_percentage_30d_in_currency: Double
    let price_change_percentage_7d_in_currency: Double
}
