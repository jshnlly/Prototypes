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
    @State private var openSearch = false
    @State private var searchOffset: Double = -72
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack (alignment: .top) {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            Text("Pull down to search")
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
                .offset(y: 300)
            // Main content
            ZStack {
                // Single diagonal line positioned at bottom right
                Path { path in
                    path.move(to: CGPoint(x: 16, y: 16))
                    path.addLine(to: CGPoint(x: 22, y: 22))
                }
                .trim(from: 0, to: CGFloat(handlePath))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.white)
                .frame(width: 20, height: 20)
                
                // Circle on top
                Circle()
                    .trim(from: 0, to: CGFloat(drawPath))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(Color.white)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -2, y: -2)
            }
            .frame(width: 56, height: 56)
            .background(openSearch ? Color.blue : Color.secondary)
            .clipShape(Circle())
            .rotationEffect(Angle(degrees: rotationEffect))
            .offset(y: CGFloat(searchOffset))
        }
        .clipped()
        .offset(y: 36)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let verticalMovement = value.translation.height
                    let progress = min(max(verticalMovement / 300, 0), 1)
                    
                    withAnimation(.snappy) {
                        drawPath = progress
                        
                        if progress > 0.5 {
                            handlePath = (progress - 0.5) * 2
                        } else {
                            handlePath = 0
                        }
                        
                        if progress >= 1 {
                            if !openSearch { // Only trigger haptic when first reaching 1
                                haptic.impactOccurred()
                            }
                            openSearch = true
                        } else {
                            openSearch = false
                        }
                        
                        rotationEffect = -90 + (progress * 90)
                        searchOffset = -72 + (verticalMovement * 0.3)
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy) {
                        drawPath = 0
                        handlePath = 0
                        rotationEffect = -90
                        searchOffset = -72
                        openSearch = false
                    }
                }
        )
        .onAppear {
            haptic.prepare() // Prepare the haptic engine
        }
    }
}

#Preview {
    ThingsSearchIcon()
}
