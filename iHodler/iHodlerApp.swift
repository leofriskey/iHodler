//
//  iHodlerApp.swift
//  iHodler
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

@main
struct iHodlerApp: App {
    
    // app delegate for device rotation controll
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // models
    @StateObject private var market = Market()
    
    var body: some Scene {
        WindowGroup {
            MainView()
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
