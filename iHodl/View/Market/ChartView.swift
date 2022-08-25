//
//  ChartView.swift
//  iHodl
//
//  Created by Leo Friskey on 25.08.2022.
//

import SwiftUI
import Charts

struct ChartView: View {
    
    @EnvironmentObject private var market: Market
    
    // init parameters
    var coin: Coin
    @State var data: [CoinChartData]
    var interval: String
    var expanded: Bool
    
    // animation state
    @State private var animate = false
    
    var body: some View {
        
        //MARK: Chart
        Chart {
            ForEach(data) { dot in
                LineMark(
                    x: .value("Time", dot.date),
                    y: .value("Price", dot.price)
                )
                .opacity(animate ? 0.3 : 1)
                .foregroundStyle(Color.primary.gradient)
            }
        }
        .chartXAxis {
            // MARK: 1D
            if interval == "1D" {
                AxisMarks(values: .stride(by: .hour, count: expanded ? 1 : 4)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour(.conversationalDefaultDigits(amPM: .narrow)))
                }
            }
            // MARK: 7D
            if interval == "7D" {
                AxisMarks(values: .stride(by: .day)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            // MARK: 30D
            if interval == "30D" {
                AxisMarks(values: .stride(by: .month)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.wide))
                }
            }
            // MARK: 1Y
            if interval == "1Y" {
                AxisMarks(values: .stride(by: .month)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(expanded ? .wide : .narrow))
                }
            }
            // MARK: All
            if interval == "All" {
                AxisMarks(values: .stride(by: .year)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.year())
                }
            }
        }
        .chartYScale(domain: (data.min(by: { $0.price < $1.price }))!.price...(data.max(by: { $0.price < $1.price }))!.price) // set bounds of y axis labels
        .onAppear {
            // animate chart on appear
            animate = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animate = false
                }
            }
        }
        .onChange(of: coin.marketData.currentPrice) { newPrice in
            // animate chart refresh
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
