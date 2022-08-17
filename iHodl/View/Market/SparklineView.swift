//
//  SparklineView.swift
//  iHodl
//
//  Created by Leo Friskey on 12.08.2022.
//

import SwiftUI

/// Credit: Kavsoft
struct SparklineView: View {
    
    var coin: CoinPreview
    var data: [CGFloat]
    var lineGradient: [Color]
    var bgGradient: [Color]
    
    @State private var graphProgress: CGFloat = 0
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                let height = geo.size.height
                let width = geo.size.width / CGFloat(data.count - 1)
                
                let maxPoint = (data.max() ?? 0)
                let minPont = (data.min() ?? 0)
                
                let points = data.enumerated().compactMap { item -> CGPoint in
                    
                    // getting progress & multiplying on height
                    let progress = (item.element - minPont) / (maxPoint - minPont)
                    let pathHeight = progress * (height - 20)
                    
                    // width
                    let pathWidth = width * CGFloat(item.offset)
                    
                    return CGPoint(x: pathWidth, y: -pathHeight + height)
                }
                
                AnimatedGraphPath(progress: graphProgress, points: points)
                .fill(
                    // Gradient
                    LinearGradient(colors: lineGradient, startPoint: .leading, endPoint: .trailing)
                )
                
                // chart bg
                fillBG()
                    .clipShape(
                        Path { path in
                            
                            // drawing the points
                            path.move(to: CGPoint(x: 0, y: 0))
                            
                            path.addLines(points)
                            
                            path.addLine(to: CGPoint(x: geo.size.width, y: height))
                            path.addLine(to: CGPoint(x: 0, y: height))
                            
                        }
                    )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        graphProgress = 1
                    }
                }
            }
            .onChange(of: coin.currentPrice) { _ in
                graphProgress = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        graphProgress = 1
                    }
                }
            }
            
        }
        
    }
    
    @ViewBuilder func fillBG() -> some View {
        LinearGradient(colors: bgGradient, startPoint: .top, endPoint: .bottom)
    }
}

struct AnimatedGraphPath: Shape {
    var progress: CGFloat
    var points: [CGPoint]
    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            // drawing the points
            path.move(to: CGPoint(x: 0, y: 0))
            
            path.addLines(points)
            
        }
        .trimmedPath(from: 0, to: progress)
        .strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}
