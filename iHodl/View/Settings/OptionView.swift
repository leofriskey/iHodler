//
//  OptionView.swift
//  iHodl
//
//  Created by Leo Friskey on 28.08.2022.
//

import SwiftUI

struct OptionView<Content: View>: View, Themeable {
    @Environment(\.colorScheme) internal var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Material02
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .frame(width: UIScreen.screenWidth * 0.94, height: UIScreen.screenHeight * 0.072)
            
            HStack {
                content
            }
            .padding(.horizontal)
            .padding(.horizontal)
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView {
            
        }
    }
}
