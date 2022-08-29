//
//  SettingsView.swift
//  iHodl
//
//  Created by Leo Friskey on 22.08.2022.
//

import SwiftUI
import Combine

struct SettingsView: View, Themeable {
    @Environment(\.colorScheme) internal var colorScheme
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var market: Market
    
    var body: some View {
        NavigationStack {
            ZStack {
                //MARK: Background
                BackgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        HStack {
                            Text("Defaults")
                                .font(.title2)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .padding([.horizontal, .top])
                        
                        VStack(spacing: 18) {
                            //MARK: Currency
                            OptionView {
                                Text("Currency")
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
                                Text("Language")
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
                                //                            .onChange(of: settings.currency) { newCurrency in
                                //                                market.connect(settings.$currencyUpdater.eraseToAnyPublisher())
                                //                            }
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
                                Text("Theme")
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
                        
                        
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
