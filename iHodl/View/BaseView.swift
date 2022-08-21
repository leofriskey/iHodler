//
//  BaseView.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import SwiftUI

struct BaseView: View {
    
    @EnvironmentObject private var viewRouter: ViewRouter
    @StateObject private var settings = Settings()
    
    var body: some View {
        switch viewRouter.currentPage {
        case .home:
            MainView()
                .environmentObject(settings)
        }
    }
}
