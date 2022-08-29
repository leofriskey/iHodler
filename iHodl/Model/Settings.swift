//
//  Settings.swift
//  iHodl
//
//  Created by Leo Friskey on 21.08.2022.
//

import SwiftUI
import Combine

class Settings: ObservableObject {
    
    //MARK: Currency
    @AppStorage("currency") var currency = "usd"
    @Published var currencyUpdater = "" // <- for feeding Market model since Combine cant handle AppStorage
    let currencies = ["usd", "rub"]
    var currencySymbol: String {
        currency == "usd" ? "$" : "₽"
    }
    
    //MARK: Language
    @AppStorage("language") var language = "en"
    let languages = ["en", "ru"]
    let marketTitle = "Market"
    let top10Title = "Top 10"
    let noData = "no data"
    
    // search
    let searchStartSuggestion = "Type at least 3 characters and press 'Search' to begin searching..."
    let noCoinsForSearchQuery = "Could not found any coin for this word... Check spelling or try another one."
    
    // watchlist
    let removeFromWatchlistTitle = "Remove from watchlist"
    let addToWatchlistTitle = "Add to watchlist"
    let watchlistTitle = "Watchlist"
    let watchlistAbout = "Add coins to watchlist by holding on them"
    
    //MARK: Theme
    @AppStorage("theme") var theme = "Auto"
    let themes = ["Light", "Dark", "Auto"]
    
    func changeTheme(to theme: String) {
        if theme == "Dark" {
            let scenes = UIApplication.shared.connectedScenes
            guard let scene = scenes.first as? UIWindowScene else { return }
            scene.keyWindow?.overrideUserInterfaceStyle = .dark
        }
        if theme == "Light" {
            let scenes = UIApplication.shared.connectedScenes
            guard let scene = scenes.first as? UIWindowScene else { return }
            scene.keyWindow?.overrideUserInterfaceStyle = .light
        }
        if theme == "Auto" {
            let scenes = UIApplication.shared.connectedScenes
            guard let scene = scenes.first as? UIWindowScene else { return }
            scene.keyWindow?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    init() {
        if self.theme == "Light" {
            self.changeTheme(to: "Light")
        }
        if self.theme == "Auto" {
            self.changeTheme(to: "Auto")
        }
        if self.theme == "Dark" {
            self.changeTheme(to: "Dark")
        }
    }
}
