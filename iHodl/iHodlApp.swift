//
//  iHodlApp.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

@main
struct iHodlApp: App {
    
    @StateObject private var viewRouter = ViewRouter()
    @StateObject private var market = Market()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewRouter)
                .environmentObject(market)
        }
    }
}
