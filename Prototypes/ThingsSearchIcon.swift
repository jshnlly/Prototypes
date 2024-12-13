//
//  ThingsSearchIcon.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/12/24.
//

import SwiftUI

struct ThingsSearchIcon: View {
    
    @State private var drawPath = 0.0
    @State private var handlePath = 0.0
    @State private var rotationEffect: Double = -90
    
    var body: some View {
        ZStack {
            // Single diagonal line positioned at bottom right
            Path { path in
                path.move(to: CGPoint(x: 16, y: 16))     // Start at bottom right of circle
                path.addLine(to: CGPoint(x: 22, y: 22))   // Extend diagonally out
            }
            .trim(from: 0, to: CGFloat(handlePath))
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .frame(width: 20, height: 20)
            
            // Circle on top
            Circle()
                .trim(from: 0, to: CGFloat(drawPath))
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(-90))
                .offset(x: -2, y: -2)
        }
        .frame(width: 56, height: 56)
        .background(Color.lightBlue)
        .clipShape(Circle())
        .rotationEffect(Angle(degrees: rotationEffect))
        .gesture(
            DragGesture()
                .onChanged { value in
                    let verticalMovement = value.translation.height
                    let progress = verticalMovement / 100
                    
                    withAnimation(.snappy) {
                        drawPath = min(max(progress, 0), 1)
                        
                        if progress > 0.5 {
                            handlePath = min((progress - 0.5) * Double(2), 1)
                        } else {
                            handlePath = 0
                        }
                        
                        rotationEffect = -90 + (drawPath * 90)
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeIn) {
                        drawPath = 0
                        handlePath = 0
                        rotationEffect = -90
                    }
                }
        )
    }
}

#Preview {
    ThingsSearchIcon()
}
