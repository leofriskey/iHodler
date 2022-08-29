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
    // app delegate for device rotation controll
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

//MARK: Device orientation control
class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.portrait //By default: portrait only

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
