//
//  SettingsView.swift
//  iHodl
//
//  Created by Leo Friskey on 22.08.2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: Settings
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Background
                colorScheme == .dark ? LinearGradient.darkBG.ignoresSafeArea() : LinearGradient.lightBG.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        HStack {
                            Text("Defaults")
                                .font(.title2)
                                .fontWeight(.light)
                            Spacer()
                        }
                        .padding()
                        // Change Theme
                        ZStack {
                            colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light
                            
                            HStack {
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
                                        .fill(
                                            colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light
                                        )
                                    ( colorScheme == .dark ?
                                    Image(systemName: "moon.fill").font(.system(size: 12))
                                    :
                                    Image(systemName: "sun.max.fill").font(.system(size: 12)) )
                                }
                                .frame(width: 20, height: 20)
                            }
                            .padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07)
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
