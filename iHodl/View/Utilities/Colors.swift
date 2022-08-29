//
//  Colors.swift
//  iHodl
//
//  Created by Leo Friskey on 10.08.2022.
//

import SwiftUI

extension LinearGradient {
    static let darkBG = LinearGradient(colors: [Color(red: 46/255, green: 53/255, blue: 80/255), Color(red: 25/255, green: 24/255, blue: 42/255)], startPoint: .top, endPoint: .bottom)
    
    static let lightBG = LinearGradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255), Color(red: 223/255, green: 223/255, blue: 240/255)], startPoint: .top, endPoint: .bottom)
    
    
    static let Material02dark = LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.066)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let Material05dark = LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.165)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let Material02light = LinearGradient(colors: [Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.12), Color(red: 108/255, green: 108/255, blue: 108/255, opacity: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let Material05light = LinearGradient(colors: [Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.3), Color(red: 108/255, green: 108/255, blue: 108/255, opacity: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
}

protocol Themeable {
    var colorScheme: ColorScheme { get }
}

extension Themeable {
    var BackgroundColor: LinearGradient {
        colorScheme == .dark ? LinearGradient.darkBG : LinearGradient.lightBG
    }
    
    var Material02: LinearGradient {
        colorScheme == .dark ? LinearGradient.Material02dark : LinearGradient.Material02light
    }
    
    var Material05: LinearGradient {
        colorScheme == .dark ? LinearGradient.Material05dark : LinearGradient.Material05light
    }
}
