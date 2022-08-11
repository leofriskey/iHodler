//
//  Market.swift
//  iHodl
//
//  Created by Leo Friskey on 11.08.2022.
//

import SwiftUI

@MainActor class Market: ObservableObject {
    // MARK: Lang
    let title = "Market"
    let top100Title = "Top 10"
    
    // MARK: Top 100 Coins
    @Published private(set) var top100Coins = [Coin_Preview]()
    
    func fetchTop100Coins() async throws {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=1h%2C24h%2C7d%2C30d%2C1y") else { return }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        
        let (data, _) = try await session.data(from: url)
        
        if let decodedResponse = try? JSONDecoder().decode([Coin_Preview].self, from: data) {
            top100Coins = decodedResponse
        }
    }
}
