//
//  SettingsView.swift
//  iHodl
//
//  Created by Leo Friskey on 22.08.2022.
//

import StoreKit
import SwiftUI
import Combine

struct SettingsView: View, Themeable {
    @Environment(\.colorScheme) internal var colorScheme
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var market: Market
    
    private var githubImage: some View {
        Image("github")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Material05)
                    .frame(width: 32, height: 32)
            )
    }
    
    private var telegramImage: some View {
        Image("telegram")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(Material05)
                    .frame(width: 32, height: 32)
            )
    }
    private var linkedInImage: some View {
        Image("linkedIn")
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .fill(Material05)
                    .frame(width: 32, height: 32)
            )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: Background
                BackgroundColor.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack {
                        
                        // Spacer
                        ZStack(alignment: .top) {
                            Color.clear
                                .frame(height: UIScreen.screenHeight * 0.01)
                        }
                        
                        //MARK: Defaults
                        HStack {
                            Text(settings.defaultsTitle)
                                .font(.title2)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                        
                        VStack(spacing: 18) {
                            //MARK: Currency
                            OptionView {
                                Text(settings.currencyTitle)
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                Spacer()
                                Picker("Choose a currency", selection: $settings.currency) {
                                    ForEach(settings.currencies, id: \.self) { currency in
                                        currency == "usd" ? Text("$") : Text("₽")
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                                .onChange(of: settings.currency) { newCurrency in
                                    settings.currencyUpdater = newCurrency
                                    market.connect(settings.$currencyUpdater.eraseToAnyPublisher())
                                    
                                    Task {
                                        do {
                                            // call API again to update data for new currency
                                            try await market.fetchTop10Coins()
                                            try await market.fetchWatchlist()
                                        } catch {
                                            print("Failed to fetch data on currency change: \(error.localizedDescription)")
                                        }
                                    }
                                }
                                ZStack {
                                    Circle()
                                        .fill(Material05)
                                    Image(systemName: "dollarsign")
                                        .font(.system(size: 12))
                                }
                                .frame(width: 20, height: 20)
                            }
                            
                            
                            //MARK: Language
                            OptionView {
                                Text(settings.languageTitle)
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                Spacer()
                                Picker("Choose a language", selection: $settings.language) {
                                    ForEach(settings.languages, id: \.self) { language in
                                        language == "en" ? Text("English") : Text("Русский")
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                                ZStack {
                                    Circle()
                                        .fill(Material05)
                                    Image(systemName: "signature")
                                        .font(.system(size: 11))
                                }
                                .frame(width: 20, height: 20)
                            }
                            
                            
                            //MARK: Theme
                            OptionView {
                                Text(settings.themeTitle)
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                Spacer()
                                Picker("Choose a theme", selection: $settings.theme) {
                                    ForEach(settings.themes, id: \.self) { theme in
                                        Text(theme)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                                .onChange(of: settings.theme) { newValue in
                                    withAnimation(.easeOut(duration: 1)) {
                                        settings.changeTheme(to: newValue)
                                    }
                                }
                                ZStack {
                                    Circle()
                                        .fill(Material05)
                                    
                                    ( colorScheme == .dark ?
                                    Image(systemName: "moon.fill").font(.system(size: 12))
                                    :
                                    Image(systemName: "sun.max.fill").font(.system(size: 12)) )
                                }
                                .frame(width: 20, height: 20)
                            }
                        }
                        
                        // Spacer
                        Color.clear
                            .frame(height: UIScreen.screenHeight * 0.05)
                        
                        //MARK: Support app
                        HStack {
                            Text(settings.supportAppTitle)
                                .font(.title2)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                        
                        VStack(spacing: 18) {
                            //MARK: Rate on App Store
                            Button {
                                requestReview()
                            } label: {
                                OptionView {
                                    Text(settings.rateAppTitle)
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                }
                            }
                            
                            //MARK: Contribute on GitHub
                            Link(destination: URL(string: "https://github.com/leofriskey/iHodl")!) {
                                OptionView {
                                    Text(settings.githubTitle)
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                    Spacer()
                                    githubImage
                                }
                            }
                            
                            //MARK: Donate
                            OptionView {
                                Text(settings.donateTitle)
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                VStack(alignment: .leading) {
                                    Text("bitcoin:")
                                        .fontWeight(.light)
                                        .font(.system(size: 14))
                                    Text(settings.btcAddress)
                                        .lineLimit(1)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 5)
                                Button("\(settings.language == "en" ? "Copy" : "Копировать")") {
                                    settings.copyToClipboard(settings.btcAddress)
                                }
                                .tint(.blue)
                            }
                        }
                        
                        // Spacer
                        Color.clear
                            .frame(height: UIScreen.screenHeight * 0.05)
                        
                        //MARK: Contact me
                        HStack {
                            Text(settings.contactMeTitle)
                                .font(.title2)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                        
                        VStack(spacing: 18) {
                            //MARK: Social links
                            OptionView {
                                Text(settings.socialLinks)
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                Spacer()
                                //MARK: Telegram
                                Link(destination: URL(string: "https://t.me/leofriskey")!) {
                                    telegramImage
                                }
                                .padding(.trailing, 15)
                                //MARK: LinkedIn
                                Link(destination: URL(string: "https://www.linkedin.com/in/leofriskey/")!) {
                                    linkedInImage
                                }
                                .padding(.trailing, 15)
                                //MARK: GitHub
                                Link(destination: URL(string: "https://github.com/leofriskey")!) {
                                    githubImage
                                }
                            }
                        }
                        
                        // Spacer
                        Color.clear
                            .frame(height: UIScreen.screenHeight * 0.1)
                        
                    }
                }
            }
            .navigationTitle(settings.settingsTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Link("Data from CoinGecko", destination: URL(string: "https://www.coingecko.com/api")!)
                        .fontWeight(.light)
                        .font(.caption)
                }
            }
            .onAppear {
                // disallow to rotate device
                AppDelegate.orientationLock = .portrait
            }
        }
        .copySuccessPopover(settings.showCopyPopover, label: settings.btcCopiedLabel)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
