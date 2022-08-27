//
//  iHodlApp.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

@main
struct iHodlApp: App {
    
    @StateObject private var network = Network()
    
    // views
    @StateObject private var market = Market()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(network)
                .environmentObject(market)
        }
    }
}
