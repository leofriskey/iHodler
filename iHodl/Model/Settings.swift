//
//  Settings.swift
//  iHodl
//
//  Created by Leo Friskey on 21.08.2022.
//

import SwiftUI

class Settings: ObservableObject {
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
