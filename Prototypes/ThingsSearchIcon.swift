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
    @State private var pullComplete = false
    @State private var searchOffset: Double = 0
    @State private var openSearch = false
    @State private var searchIconScale: Double = 0.8
    @State private var searchIconOpacity: Double = 0
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            let initialOffset = -geometry.safeAreaInsets.top
            
            ZStack (alignment: .top) {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                Text("Pull down to search")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .offset(y: 375)
                
                // Search panel
                ZStack {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 24))
                        .opacity(0.3)
                }
                .frame(width: 120, height: 120)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: openSearch)
                .opacity(openSearch ? 1 : 0)
                .scaleEffect(openSearch ? 1 : 0.8)
                .offset(y: openSearch ? 64 : 40)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        openSearch = false
                    }
                }
                
                // Main content (search icon)
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
                .background(pullComplete ? Color.blue : Color.secondary)
                .clipShape(Circle())
                .rotationEffect(Angle(degrees: rotationEffect))
                .scaleEffect(searchIconScale)
                .opacity(searchIconOpacity)
                .offset(y: searchOffset == 0 ? initialOffset : CGFloat(searchOffset))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            haptic.prepare()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let verticalMovement = value.translation.height
                    let progress = min(max(verticalMovement / 200, 0), 1)
                    
                    withAnimation(.snappy) {
                        drawPath = progress
                        searchIconScale = 0.8 + (progress * 0.2)
                        searchIconOpacity = progress
                        
                        if progress > 0.5 {
                            handlePath = (progress - 0.5) * 2
                        } else {
                            handlePath = 0
                        }
                        
                        if progress >= 1 {
                            if !pullComplete {
                                haptic.impactOccurred()
                            }
                            pullComplete = true
                        } else {
                            pullComplete = false
                        }
                        
                        rotationEffect = -90 + (progress * 90)
                        searchOffset = 0 + (verticalMovement * 0.3)
                    }
                }
                .onEnded { _ in
                    withAnimation(.snappy) {
                        drawPath = 0
                        handlePath = 0
                        rotationEffect = -90
                        searchOffset = 0
                        searchIconScale = 0.8
                        searchIconOpacity = 0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.snappy) {
                                pullComplete = false
                            }
                        }
                        
                        if pullComplete == true {
                            openSearch = true
                        }
                    }
                }
        )
    }
}

#Preview {
    ThingsSearchIcon()
}
