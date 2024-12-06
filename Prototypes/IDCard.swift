//
//  IDCard.swift
//  Prototypes
//
//  Created by Josh Nelson on 11/19/24.
//

import SwiftUI
import UIKit

struct IDCard: View {
    @State var dragLocation = CGPoint(x: 0, y: 0)
    @State var shadowOffset = CGPoint(x: 0, y: 0)
    @State var isDragging = false
    @State private var isFlipped = false
    @State private var flipRotation: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    @State private var shadowScale: CGFloat = 1.0
    @State private var frontImageIndex: Int = 0
    @State private var lastTapTime: Date = Date()
    @State private var tapCount: Int = 0
    
    // Haptic generators
    private let softHaptic = UIImpactFeedbackGenerator(style: .soft)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    var width: CGFloat = 340
    var height: CGFloat = 200
    
    var intensity: CGFloat = 4
    var maxShadowOffset: CGFloat = 15
    
    private let frontImages = ["hayes-front", "hayes-front2"]
    private let doubleTapTimeThreshold: TimeInterval = 0.3
    
    private func playTapHaptic() {
        softHaptic.impactOccurred()
    }
    
    private func playFlipHaptic() {
        mediumHaptic.impactOccurred(intensity: 1.0)
        
        // Add a slight delay and second haptic for more emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mediumHaptic.impactOccurred(intensity: 0.7)
        }
    }
    
    func scale(inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat, value: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }
    
    private func handleTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)
        lastTapTime = now
        
        if timeSinceLastTap < doubleTapTimeThreshold {
            // Double tap - perform flip immediately
            tapCount = 0
            scale = 0.875
            
            // Play the more intense flip haptic
            playFlipHaptic()
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
                flipRotation = isFlipped ? 180 : 0
                shadowScale = 0.4
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    scale = 1.0
                    shadowScale = 1.0
                }
            }
        } else {
            // Single tap - wait briefly to confirm it's not a double tap
            tapCount += 1
            let currentTapCount = tapCount
            
            // Play the simple tap haptic
            playTapHaptic()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Only proceed if another tap hasn't occurred
                guard currentTapCount == tapCount else { return }
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 0.875
                    shadowScale = 0.4
                    frontImageIndex = (frontImageIndex + 1) % frontImages.count
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scale = 1.0
                        shadowScale = 1.0
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                // Shadow layer stays outside the flip rotation
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.clear)
                    .frame(width: width-4, height: height-4)
                    .gradientShadow(
                        gradient: Gradient(colors: [isFlipped ? .purple : .blue,
                                                 isFlipped ? .blue : .purple,
                                                 isFlipped ? .purple : .blue]),
                        radius: 16,
                        x: -shadowOffset.x,
                        y: -shadowOffset.y
                    )
                    .scaleEffect(shadowScale)
                
                // Card content with front and back always present
                ZStack {
                    // Front card
                    Image(frontImages[frontImageIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: width-4, height: height-4)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .opacity(isFlipped ? 0 : 1)
                    
                    // Back card
                    Image("hayes-back")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width-4, height: height-4)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                        .opacity(isFlipped ? 1 : 0)
                }
                .rotation3DEffect(.degrees(dragLocation.x), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(dragLocation.y), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(flipRotation), axis: (x: 1, y: 0, z: 0))
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { gesture in
                        let normalizedX = scale(inputMin: 0, inputMax: width-4, outputMin: -intensity, outputMax: intensity, value: gesture.location.x)
                        let normalizedY = scale(inputMin: 0, inputMax: height-4, outputMin: intensity, outputMax: -intensity, value: gesture.location.y)
                        
                        let shadowX = scale(inputMin: 0, inputMax: width-4, outputMin: -maxShadowOffset, outputMax: maxShadowOffset, value: gesture.location.x)
                        let shadowY = scale(inputMin: 0, inputMax: height-4, outputMin: -maxShadowOffset, outputMax: maxShadowOffset, value: gesture.location.y)
                        
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                            dragLocation = CGPoint(x: normalizedX, y: normalizedY)
                            shadowOffset = CGPoint(x: shadowX, y: shadowY)
                        }
                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            dragLocation = .zero
                            shadowOffset = .zero
                        }
                    }
            )
            .onTapGesture {
                handleTap()
            }
            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0), perspective: 0.3)
        }
        .scaleEffect(scale)
    }
}

struct GradientShadowModifier: ViewModifier {
    let gradient: Gradient
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    private var shadowIntensity: CGFloat {
        let distance = sqrt(x * x + y * y)
        return 1.0 + (distance / 50.0)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.clear)
                .background(
                    AngularGradient(
                        gradient: gradient,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    )
                )
                .blur(radius: radius * 1.5)
                .offset(x: x, y: y)
                .opacity(0.3 * shadowIntensity)
            
            content
                .foregroundColor(.clear)
                .background(
                    AngularGradient(
                        gradient: gradient,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    )
                )
                .blur(radius: radius)
                .offset(x: x * 0.8, y: y * 0.8)
                .opacity(0.2 * shadowIntensity)
            
            content
        }
    }
}

extension View {
    func gradientShadow(gradient: Gradient, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        modifier(GradientShadowModifier(gradient: gradient, radius: radius, x: x, y: y))
    }
}
