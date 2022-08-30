//
//  Settings.swift
//  iHodl
//
//  Created by Leo Friskey on 21.08.2022.
//

import SwiftUI
import Combine

final class Settings: ObservableObject {
    
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
    
    //MARK: market
    var marketTitle: String {
        language == "en" ? "Market" : "Рынок"
    }
    var top10Title: String {
        language == "en" ? "Top 10" : "Топ 10"
    }
    var coinCaption: String {
        language == "en" ? "Coin" : "Монета"
    }
    var priceCaption: String {
        language == "en" ? "Price" : "Цена"
    }
    var noData: String {
        language == "en" ? "no data" : "нет данных"
    }
    var globalCaption: String {
        language == "en" ? "Price change" : "Изменение цены"
    }
    var globalTitle: String {
        language == "en" ? "Overview" : "Обзор"
    }
    
    //MARK: picker
    var d1Title: String {
        language == "en" ? "1D" : "1Д"
    }
    var d7Title: String {
        language == "en" ? "7D" : "7Д"
    }
    var d30Title: String {
        language == "en" ? "30D" : "30Д"
    }
    var y1Title: String {
        language == "en" ? "1Y" : "1Г"
    }
    var allTitle: String {
        language == "en" ? "All" : "Все"
    }
    
    
    //MARK: search
    var searchPrompt: String {
        language == "en" ? "Search for all coins" : "Поиск по всем криптовалютам"
    }
    var searchStartSuggestion: String {
        language == "en" ? "Type at least 3 characters and press 'Search' to begin searching..." : "Напишите как минимум 3 символа и нажмите 'Найти' для того чтобы начать поиск..."
    }
    var noCoinsForSearchQuery: String {
        language == "en" ? "Could not found any coin for this word... Check spelling or try another one." : "Нет данных по этому запросу... Проверьте написание или попробуйте другое слово."
    }
    
    //MARK: watchlist
    var removeFromWatchlistTitle: String {
        language == "en" ? "Remove from watchlist" : "Убрать из избранного"
    }
    var addToWatchlistTitle: String {
        language == "en" ? "Add to watchlist" : "Добавить в избранное"
    }
    var watchlistTitle: String {
        language == "en" ? "Watchlist" : "Избранное"
    }
    var watchlistAbout: String {
        language == "en" ? "Add coins to watchlist by holding on them" : "Чтобы добавить в избранное, нажмите монету и удерживайте"
    }
    
    //MARK: CoinDetail
    var statsTitle: String {
        language == "en" ? "Stats" : "Показатели"
    }
    var volume1DTitle: String {
        language == "en" ? "Volume 1D" : "Объем 1Д"
    }
    var marketCapTitle: String {
        language == "en" ? "Market Cap" : "Капитализация"
    }
    var circulatingSupplyTitle: String {
        language == "en" ? "Circulating Supply" : "В обороте"
    }
    var linksTitle: String {
        language == "en" ? "Links" : "Cсылки"
    }
    var sourceCodeTitle: String {
        language == "en" ? "Source code" : "Исходный код"
    }
    
    
    //MARK: settings
    var settingsTitle: String {
        language == "en" ? "Settings" : "Настройки"
    }
    
    //MARRK: defaults
    var defaultsTitle: String {
        language == "en" ? "Defaults" : "Основные"
    }
    var currencyTitle: String {
        language == "en" ? "Currency" : "Валюта"
    }
    var languageTitle: String {
        language == "en" ? "Language" : "Язык"
    }
    var themeTitle: String {
        language == "en" ? "Theme" : "Тема"
    }
    
    //MARK: support app
    var supportAppTitle: String {
        language == "en" ? "Support iHodl" : "Поддержать iHodl"
    }
    var rateAppTitle: String {
        language == "en" ? "Rate on App Store" : "Оценить в App Store"
    }
    var githubTitle: String {
        language == "en" ? "Contribute on Github" : "Помочь на Github"
    }
    var donateTitle: String {
        language == "en" ? "Donate" : "Донат"
    }
    
    //MARK: contact me
    var contactMeTitle: String {
        language == "en" ? "Contact Me" : "Мои контакты"
    }
    var socialLinks: String {
        language == "en" ? "Social links" : "Cоц сети"
    }
    
    
    //MARK: Donate
    @Published private(set) var btcAddress = "bc1qesmnk5r6v7asczk63qszdew8mpwdy6cp5gfyfu"
    
    func copyToClipboard(_ field: String) {
        UIPasteboard.general.string = field
        
        self.showCopyPopover = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 3)) {
                self.showCopyPopover = false
            }
        }
    }
    
    @Published private(set) var showCopyPopover = false
    var btcCopiedLabel: String {
        language == "en" ? "Bitcoin address copied!" : "Bitcoin адрес скопирован!"
    }
    
    
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
    
    //MARK: Init
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
