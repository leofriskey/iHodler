//
//  LinkView.swift
//  iHodl
//
//  Created by Leo Friskey on 27.08.2022.
//

import SwiftUI

enum AboutLink {
    case website, whitepaper, sourcecode
}

struct LinkView: View, Themeable {
    
    let type: AboutLink
    let url: String
    
    @Environment(\.colorScheme) internal var colorScheme
    
    var body: some View {
        switch type {
        case .website:
            HStack(spacing: 4) {
                Image(systemName: "globe")
                    .font(.system(size: 14))
                if let webURL = URL(string: url) {
                    if let domain = webURL.host() {
                        Link(domain, destination: webURL)
                            .font(.system(size: 14))
                    } else {
                        Link("website", destination: webURL)
                            .font(.system(size: 14))
                    }
                } else {
                    Text("no data")
                        .font(.system(size: 14))
                }
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .padding(7)
            .frame(height: 22)
            .background(
                Material02
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            )
        case .whitepaper:
            HStack(spacing: 4) {
                Image(systemName: "doc.plaintext")
                    .font(.system(size: 14))
                if let webURL = URL(string: url) {
                    Link("Whitepaper", destination: webURL)
                        .font(.system(size: 14))
                } else {
                    Text("no data")
                        .font(.system(size: 14))
                }
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .padding(7)
            .frame(height: 22)
            .background(
                Material02
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            )
        case .sourcecode:
            HStack(spacing: 4) {
                Image(systemName: "ellipsis.curlybraces")
                    .font(.system(size: 14))
                if let webURL = URL(string: url) {
                    Link("Source code", destination: webURL)
                        .font(.system(size: 14))
                } else {
                    Text("no data")
                        .font(.system(size: 14))
                }
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }
            .padding(7)
            .frame(height: 22)
            .background(
                Material02
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            )
        }
    }
}
