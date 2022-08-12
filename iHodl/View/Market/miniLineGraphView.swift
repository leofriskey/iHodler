//
//  miniLineGraphView.swift
//  iHodl
//
//  Created by Leo Friskey on 12.08.2022.
//

import SwiftUI

/// Credit: Kavsoft
struct miniLineGraphView: View {
    
    var data: [CGFloat]
    var lineGradient: [Color]
    var bgGradient: [Color]
    
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
                
                Path { path in
                    
                    // drawing the points
                    path.move(to: CGPoint(x: 0, y: 0))
                    
                    path.addLines(points)
                    
                }
                .strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
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
            
        }
        
    }
    
    @ViewBuilder func fillBG() -> some View {
        LinearGradient(colors: bgGradient, startPoint: .top, endPoint: .bottom)
    }
}
