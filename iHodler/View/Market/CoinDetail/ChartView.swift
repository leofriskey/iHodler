//
//  ChartView.swift
//  iHodler
//
//  Created by Leo Friskey on 25.08.2022.
//

import SwiftUI
import Charts

enum ChartType {
    case real, overlayYAxis
}

struct ChartView: View {
    
    //MARK: environment
    @EnvironmentObject private var market: Market
    @Environment(\.colorScheme) private var colorScheme
    
    //MARK: init parameters
    var coin: Coin?
    @State var data: [CoinChartData]
    var interval: String
    
    //MARK: animation state
    @State private var animate = false
    
    //MARK: priceviewerInfo
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
                
                //MARK: Current price rule mark
                if data.last?.price != nil && showDetailPrice == false {
                    RuleMark(y: .value("Price", data.last!.price))
                        .foregroundStyle(Color.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
                
                //MARK: Current viewfinder item rule mark
                if let currentActiveItem = market.currentActiveItem, currentActiveItem.id == dot.id {
                    RuleMark(x: .value("Date", currentActiveItem.date))
                        .foregroundStyle(Color.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    RuleMark(y: .value("Price", currentActiveItem.price))
                        .foregroundStyle(Color.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false), range: .plotDimension(startPadding: 5, endPadding: 5))
        //MARK: priceFinder
        .chartOverlay { chartProxy in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { newValue in
                            
                            showDetailPrice = true

                            let location = newValue.location

                            if let date: Date = chartProxy.value(atX: location.x) {

                                let calendar = Calendar.current

                                if interval == "1D" {
                                    if let currentItem = data.first(where: { item in
                                        calendar.isDate(date, equalTo: item.date, toGranularity: .hour)
                                    }) {
                                        market.currentActiveItem = currentItem
                                    }
                                }
                                if interval == "7D" {
                                    if let currentItem = data.first(where: { item in
                                        calendar.isDate(date, equalTo: item.date, toGranularity: .hour)
                                    }) {
                                        market.currentActiveItem = currentItem
                                    }
                                }
                                if interval == "30D" {
                                    if let currentItem = data.first(where: { item in
                                        calendar.isDate(date, equalTo: item.date, toGranularity: .hour)
                                    }) {
                                        market.currentActiveItem = currentItem
                                    }
                                }
                                if interval == "1Y" {
                                    if let currentItem = data.first(where: { item in
                                        calendar.isDate(date, equalTo: item.date, toGranularity: .day)
                                    }) {
                                        market.currentActiveItem = currentItem
                                    }
                                }
                                if interval == "All" {
                                    if let currentItem = data.first(where: { item in
                                        calendar.isDate(date, equalTo: item.date, toGranularity: .weekOfMonth)
                                    }) {
                                        market.currentActiveItem = currentItem
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            showDetailPrice = false
                            market.currentActiveItem = nil
                        }
                )
        }
        .drawingGroup()
        .onChange(of: coin?.marketData.currentPrice) { newPrice in
            //MARK: animate chart refresh
            if market.oldMarketData?.currentPrice != newPrice {
                animate = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animate = false
                    }
                }
            }
        }
        
    }
}
