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
    
    
    static let material02dark = LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.066)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let material05dark = LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.165)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let material02light = LinearGradient(colors: [Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.12), Color(red: 108/255, green: 108/255, blue: 108/255, opacity: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    static let material05light = LinearGradient(colors: [Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.3), Color(red: 108/255, green: 108/255, blue: 108/255, opacity: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
}
