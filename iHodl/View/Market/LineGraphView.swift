//
//  LineGraphView.swift
//  iHodl
//
//  Created by Leo Friskey on 12.08.2022.
//


import SwiftUI

/// Credit: Kavsoft
struct LineGraphView: View {
    
    var data: [CGFloat]
//    var color1: Color
//    var color2: Color
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                let height = geo.size.height
                let width = geo.size.width / CGFloat(data.count - 1)
                
                let maxPoint = (data.max() ?? 0)
                let minPont = (data.min() ?? 0) - 100
                
                let points = data.enumerated().compactMap { item -> CGPoint in
                    
                    // getting progress & multiplying on height
                    let progress = (item.element - minPont) / (maxPoint - minPont)
                    let pathHeight = progress * (height - 30)
                    
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
                    LinearGradient(colors: [.green.opacity(0.7), .green], startPoint: .leading, endPoint: .trailing)
                )
                
                // chart bg
//                fillBG()
//                    .clipShape(
//                        Path { path in
//
//                            // drawing the points
//                            path.move(to: CGPoint(x: 0, y: 0))
//
//                            path.addLines(points)
//
//                            path.addLine(to: CGPoint(x: geo.size.width, y: height))
//                            path.addLine(to: CGPoint(x: 0, y: height))
//
//                        }
//                    )
            }
            
        }
        
    }
    
    @ViewBuilder func fillBG() -> some View {
        LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0)], startPoint: .top, endPoint: .bottom)
    }
}

struct LineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView().environment(\.colorScheme, .dark).environmentObject(Market())
    }
}
