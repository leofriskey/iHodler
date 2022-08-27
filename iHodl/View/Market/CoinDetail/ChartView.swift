//
//  ChartView.swift
//  iHodl
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
    var coin: Coin
    @State var data: [CoinChartData]
    var interval: String
    var expanded: Bool
    var type: ChartType
    var showDetailPrice: Bool
    
    //MARK: animation state
    @State private var animate = false
    
    var body: some View {
        
        switch type {
        case .real:
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
                    if showDetailPrice {
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
            }
            .chartYScale(domain: (data.min(by: { $0.price < $1.price }))!.price...(data.max(by: { $0.price < $1.price }))!.price) // set bounds of y axis labels
            //MARK: priceFinder
            .chartOverlay(content: { chartProxy in
                GeometryReader { geoProxy in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { newValue in
                                    guard showDetailPrice else { return }
                                    
                                    let location = newValue.location
                                    
                                    if let date: Date = chartProxy.value(atX: location.x) {
                                        
                                        let calendar = Calendar.current
                                        
                                        if interval == "1D" {
                                            if let currentItem = data.first(where: { item in
                                                calendar.isDate(date, equalTo: item.date, toGranularity: .minute)
                                            }) {
                                                market.currentActiveItem = currentItem
                                                print(currentItem.date)
                                            }
                                        }
                                        if interval == "7D" {
                                            if let currentItem = data.first(where: { item in
                                                calendar.isDate(date, equalTo: item.date, toGranularity: .hour)
                                            }) {
                                                market.currentActiveItem = currentItem
                                                print(currentItem.date)
                                            }
                                        }
                                        if interval == "30D" {
                                            if let currentItem = data.first(where: { item in
                                                calendar.isDate(date, equalTo: item.date, toGranularity: .hour)
                                            }) {
                                                market.currentActiveItem = currentItem
                                                print(currentItem.date)
                                            }
                                        }
                                        if interval == "1Y" {
                                            if let currentItem = data.first(where: { item in
                                                calendar.isDate(date, equalTo: item.date, toGranularity: .day)
                                            }) {
                                                market.currentActiveItem = currentItem
                                                print(currentItem.date)
                                            }
                                        }
                                        if interval == "All" {
                                            if let currentItem = data.first(where: { item in
                                                calendar.isDate(date, equalTo: item.date, toGranularity: .day)
                                            }) {
                                                market.currentActiveItem = currentItem
                                                print(currentItem.date)
                                            }
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    market.currentActiveItem = nil
                                }
                        )
                }
            })
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
        case .overlayYAxis:
            //MARK: Y Axis Overlay
            Chart {
                ForEach(data) { dot in
                    LineMark(
                        x: .value("Time", dot.date),
                        y: .value("Price", dot.price)
                    )
                    .opacity(0)
                    
                }
            }
            .chartXAxis(.hidden)
            .chartYScale(domain: (data.min(by: { $0.price < $1.price }))!.price...(data.max(by: { $0.price < $1.price }))!.price) // set bounds of y axis labels
        }
        
    }
}
