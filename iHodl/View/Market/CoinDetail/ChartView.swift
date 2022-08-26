//
//  ChartView.swift
//  iHodl
//
//  Created by Leo Friskey on 25.08.2022.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    //MARK: environment
    @EnvironmentObject private var market: Market
    @Environment(\.colorScheme) private var colorScheme
    
    //MARK: init parameters
    var coin: Coin
    @State var data: [CoinChartData]
    var interval: String
    var expanded: Bool
    
    //MARK: animation state
    @State private var animate = false
    
    //MARK: popover
    @State private var showDetailPrice = false
    
    var body: some View {
        
        //MARK: Chart
        Chart {
            ForEach(data) { dot in
                LineMark(
                    x: .value("Time", dot.date),
                    y: .value("Price", dot.price)
                )
                .opacity(animate ? 0.3 : 1)
                .foregroundStyle(colorScheme == .dark ? Color.primary.gradient : Color.secondary.gradient)
                
                // MARK: Current price rule mark
                if data.last?.price != nil && showDetailPrice == false {
                    RuleMark(y: .value("Price", data.last!.price))
                        .foregroundStyle(Color.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
        }
        .chartYScale(domain: (data.min(by: { $0.price < $1.price }))!.price...(data.max(by: { $0.price < $1.price }))!.price) // set bounds of y axis labels
        .onAppear {
            //MARK: animate chart on appear
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animate = false
                }
            }
        }
        .onChange(of: coin.marketData.currentPrice) { newPrice in
            //MARK: animate chart refresh
            if market.oldMarketData?.currentPrice != newPrice {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animate = false
                    }
                }
            }
        }
        
    }
}
