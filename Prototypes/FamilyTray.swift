//
//  NUXSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/14/24.
//

import SwiftUI

struct FamilyTray: View {
    static let customAnimation = Animation.timingCurve(0.17, 0.88, 0.32, 0.99, duration: 0.3)
    
    @State private var buttonWidth: CGFloat = 200
    @State private var frameWidth: CGFloat = 200
    @State private var frameHeight: CGFloat = 56
    @State private var isPressed: Bool = false
    @State private var frameRadius: CGFloat = 28
    @State private var frameShadow: CGFloat = 0
    @State private var isExpanded = false
    @State private var buttonText = "Tap to expand"
    @State private var isFullyExpanded = false
    @State private var buttonOpacity: Double = 1.0
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    
    var body: some View {
        VStack {
            
            Spacer()
            
            ZStack (alignment: .bottom) {
                // Content Layer
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tray title")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.primary)
                        
                        Spacer()
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 24))
                            .opacity(0.1)
                            .onTapGesture {
                                haptic.impactOccurred(intensity: 0.7)
                                withAnimation(FamilyTray.customAnimation) {
                                    isExpanded = false
                                    buttonWidth = 200
                                    frameWidth = 200
                                    frameHeight = 56
                                    frameRadius = 28
                                    frameShadow = 0
                                    buttonText = "Tap to expand"
                                    buttonOpacity = 1
                                }
                            }
                    }
                    .padding(.bottom, 24)
                    
                    Text("This is a recreation of a tray system originally designed for Family, the Ethereum wallet")
                        .font(.system(size: 20, design: .rounded))
                        .foregroundStyle(Color.primary.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: isExpanded ? 0 : 200)
                        .scaleEffect(isExpanded ? 1 : 0)
                    
                    Spacer()
                }
                .padding(24)
                .opacity(isExpanded ? 1 : 0)
                
                // Button Layer
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(buttonOpacity))
                        .frame(width: buttonWidth, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    
                    Text(buttonText)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(FamilyTray.customAnimation, value: isPressed)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isPressed = true
                        }
                        .onEnded { _ in
                            haptic.impactOccurred()
                            isPressed = false
                            
                            withAnimation(FamilyTray.customAnimation) {
                                if !isExpanded {  // First expansion
                                    isExpanded = true  // Move this up to animate together
                                    buttonWidth = UIScreen.main.bounds.width - 64
                                    frameWidth = UIScreen.main.bounds.width - 32
                                    frameShadow = 0.1
                                    frameHeight = 280
                                    frameRadius = 40
                                    buttonText = "One more time"
                                } else {  // Second expansion
                                    isFullyExpanded = true
                                    frameHeight = 540
                                    buttonOpacity = 0.3
                                    buttonText = "Nice!"
                                }
                            }
                        }
                )
                .padding(.bottom, isExpanded ? 0 : 24)
            }
            .frame(width: frameWidth, height: frameHeight)
            .padding(.bottom, 24)
            .background(isExpanded ? Color(UIColor.systemBackground) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: frameRadius))
            .shadow(color: Color.black.opacity(frameShadow), radius: 12)
        }
        .padding(.bottom, 32)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    FamilyTray()
}
