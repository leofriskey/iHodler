//
//  CoinDetailView.swift
//  iHodl
//
//  Created by Leo Friskey on 20.08.2022.
//

import SwiftUI

struct CoinDetailView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var market: Market
    
    let coinPreview: CoinPreview
    
    @State private var blink = false
    
    var body: some View {
        ZStack {
            // MARK: Background
            (colorScheme == .dark ? LinearGradient.darkBG.ignoresSafeArea() : LinearGradient.lightBG.ignoresSafeArea())
            
            ScrollView {
                VStack {
                    // MARK: Chart
                    ZStack {
                        ZStack {
                            // chart bg
                            Rectangle()
                                .fill(colorScheme == .dark ? LinearGradient.material02dark : LinearGradient.material02light)
                                .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.3)
                            // chart
                            ///
                            // picker
                            Picker("Chart time interval", selection: $market.chartTimePicker) {
                                ForEach(market.chartTimeIntervals, id: \.self) { interval in
                                    Text(interval)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: UIScreen.screenWidth * 0.8, height: 16)
                            .offset(x: UIScreen.screenWidth * 0.067, y: UIScreen.screenHeight * -0.15)
                        }
                    }
                    .padding()
                    // MARK: Info
                    HStack {
                        // Image
                        if coinPreview.image != nil {
                            AsyncImage(
                                url: URL(string: coinPreview.image!),
                                content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                },
                                placeholder: {
                                    Circle()
                                        .fill(colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                                        .frame(width: 40, height: 40)
                                        .opacity(blink ? 0.3 : 1)
                                        .onAppear {
                                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                                blink.toggle()
                                            }
                                        }
                                }
                            )
                        } else {
                            Image(systemName: "questionmark")
                                .foregroundColor(.secondary)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? LinearGradient.material05dark : LinearGradient.material05light)
                                )
                        }
                        // Price change
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: UIScreen.screenWidth * 1)
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(coinPreview.name)
            }
        }
    }
}
