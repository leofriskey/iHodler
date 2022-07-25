//
//  Base.swift
//  iHodl
//
//  Created by Leo Friskey on 25.07.2022.
//

import Foundation

enum Page {
    case home
}

@MainActor class ViewRouter: ObservableObject {
    var currentPage: Page = .home
}
