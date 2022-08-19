//
//  GlobalView.swift
//  iHodl
//
//  Created by Leo Friskey on 20.08.2022.
//

import SwiftUI

struct GlobalView: View {
    
    @EnvironmentObject private var market: Market
    
    @State private var xOffsets: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @State private var yOffsets: [CGFloat] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    @State private var animateCircles = false
    
    @State private var darken = false
    
    @State private var circleToRefresh: Int? = nil
    @State private var darkenOnRefresh = false
    
    let rows = [
        GridItem(.adaptive(minimum: 50), spacing: 10),
        GridItem(.adaptive(minimum: 50), spacing: 10)
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .topTrailing) {
                    // MARK: BG
                    LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.33)], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.5)
                        .clipShape(Rectangle())
                        .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.2)
                    // check if global data is here
                    if market.globalData != nil {
                        // MARK: "Overview"
                        if market.gcPicker == "Overview" {
                           
                            
                            //MARK: Placeholder while data fetching
                            if market.top10Coins.first?.symbol == "placeholder" {
                                LazyHGrid(rows: rows) {
                                    ForEach(0..<10) { num in
                                        ZStack {
                                            Circle()
                                                .fill(.white.opacity(0.3))
                                        }
                                        .frame(width: 50, height: 50)
                                        .scaleEffect(market.getScaleEffect(index: num))
                                        .offset(x: xOffsets[num], y: yOffsets[num])
                                        .opacity(animateCircles ? 0.3 : 1)
                                    }
                                }
                                .padding(.top)
                                .padding()
                                .onAppear {
                                    // animate placeholder 'loading'
                                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                        self.animateCircles.toggle()
                                    }
                                    // animate position change
                                    withAnimation(.easeOut(duration: 1)) {
                                        xOffsets = [-40.0, -8.0, -10.0, -5.0, 5.0, 8.0, -6.0, 5.0, 4.0, 3.0]
                                        yOffsets = [20.0, 20.0, -15.0, 5.0, -25.0, -20.0, 0.0, 10.0, -15.0, 20.0]
                                    }
                                }
                            // MARK: Real view
                            } else {
                                
                                
                                // MARK: 1D
                                if market.timeInterval == "1D" {
                                    LazyHGrid(rows: rows) {
                                        ForEach(0..<10) { num in
                                            ZStack {
                                                Circle()
                                                    .fill(.white.opacity(0.3))
                                                    .overlay(Circle().stroke((market.top10Coins[num].priceChangePercentage24HInCurrency ?? 0) > 0 ? .green : (market.top10Coins[num].priceChangePercentage24HInCurrency ?? 0) < 0 ? .red : .secondary))
                                                VStack {
                                                    if (market.top10Coins[num].priceChangePercentage24HInCurrency ?? 0) > 0 {
                                                        Text("+\(market.top10Coins[num].priceChangePercentage24HInCurrency ?? 0, specifier: "%.2f")%")
                                                            .font(.caption2)
                                                    } else {
                                                        Text("\(market.top10Coins[num].priceChangePercentage24HInCurrency ?? 0, specifier: "%.2f")%")
                                                            .font(.caption2)
                                                    }
                                                    Text(market.top10Coins[num].symbol)
                                                        .fontWeight(.light)
                                                        .font(.caption2)
                                                }
                                                .shadow(radius: 1)
                                                .opacity(darken ? 0.3 : 1)
                                            }
                                            .frame(width: 50, height: 50)
                                            .scaleEffect(market.getScaleEffect(index: num))
                                            .offset(x: xOffsets[num], y: yOffsets[num])
                                        }
                                    }
                                    .padding(.top)
                                    .padding()
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 1)) {
                                            xOffsets = [-40.0, -8.0, -10.0, -5.0, 5.0, 8.0, -6.0, 5.0, 4.0, 3.0]
                                            yOffsets = [20.0, 20.0, -15.0, 5.0, -25.0, -20.0, 0.0, 10.0, -15.0, 20.0]
                                        }
                                    }
                                // MARK: 7D
                                } else {
                                    LazyHGrid(rows: rows) {
                                        ForEach(0..<10) { num in
                                            ZStack {
                                                Circle()
                                                    .fill(.white.opacity(0.3))
                                                    .overlay(Circle().stroke((market.top10Coins[num].priceChangePercentage7DInCurrency ?? 0) > 0 ? .green : (market.top10Coins[num].priceChangePercentage7DInCurrency ?? 0) < 0 ? .red : .secondary))
                                                VStack {
                                                    if (market.top10Coins[num].priceChangePercentage7DInCurrency ?? 0) > 0 {
                                                        Text("+\(market.top10Coins[num].priceChangePercentage7DInCurrency ?? 0, specifier: "%.2f")%")
                                                            .font(.caption2)
                                                    } else {
                                                        Text("\(market.top10Coins[num].priceChangePercentage7DInCurrency ?? 0, specifier: "%.2f")%")
                                                            .font(.caption2)
                                                    }
                                                    Text(market.top10Coins[num].symbol)
                                                        .fontWeight(.light)
                                                        .font(.caption2)
                                                }
                                                .shadow(radius: 1)
                                                .opacity(darken ? 0.3 : 1)
                                                .opacity(circleToRefresh == num && darkenOnRefresh ? 0.3 : 1)
                                            }
                                            .frame(width: 50, height: 50)
                                            .scaleEffect(market.getScaleEffect(index: num))
                                            .offset(x: xOffsets[num], y: yOffsets[num])
                                            // animate blink on refresh
                                            .onChange(of: market.top10Coins[num].currentPrice) { newValue in
                                                circleToRefresh = num
                                                darkenOnRefresh = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.easeInOut(duration: 0.7)) {
                                                        darkenOnRefresh = false
                                                    }
                                                    circleToRefresh = nil
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top)
                                    .padding()
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 1)) {
                                            xOffsets = [-40.0, -8.0, -10.0, -5.0, 5.0, 8.0, -6.0, 5.0, 4.0, 3.0]
                                            yOffsets = [20.0, 20.0, -15.0, 5.0, -25.0, -20.0, 0.0, 10.0, -15.0, 20.0]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight * 0.2)
                .clipShape(Rectangle())
                // animate change of time interval
                .onChange(of: market.timeInterval) { newValue in
                    darken = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.7)) {
                            darken = false
                        }
                    }
                }
                // MARK: Picker
                Picker("Global statistics", selection: $market.gcPicker) {
                    ForEach(market.gcValues, id: \.self) { item in
                        Text(item)
                            .font(.caption2)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 80, height: 12) // width: 280 (3 options)
                .offset(x: -10)
            }
            // MARK: Caption
            if market.gcPicker == "Overview" {
                if market.timeInterval == "1D" {
                    Text("Price change 1D %")
                        .fontWeight(.light)
                        .font(.caption2)
                        .shadow(radius: 1)
                        .padding([.top, .leading], 20)
                } else {
                    Text("Price change 7D %")
                        .fontWeight(.light)
                        .font(.caption2)
                        .shadow(radius: 1)
                        .padding([.top, .leading], 20)
                }
            }
            if market.gcPicker == "Capitalization" {
                Text("Total market capitalization")
                    .fontWeight(.light)
                    .font(.caption2)
                    .shadow(radius: 1)
                    .padding([.top, .leading], 20)
            }
            if market.gcPicker == "Dominance" {
                Text("Coin dominance %")
                    .fontWeight(.light)
                    .font(.caption2)
                    .shadow(radius: 1)
                    .padding([.top, .leading], 20)
            }
        }
    }
}

struct GlobalView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalView()
    }
}