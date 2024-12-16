//
//  NUXSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/14/24.
//

import SwiftUI

struct FamilyTray: View {
    
    @State private var buttonWidth: CGFloat = 200
    @State private var frameWidth: CGFloat = 200
    @State private var frameHeight: CGFloat = 56
    @State private var isPressed: Bool = false
    @State private var frameRadius: CGFloat = 28
    @State private var frameShadow: CGFloat = 0
    @State private var isExpanded = false
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            
            Spacer()
            
            ZStack (alignment: .bottom) {
                
                
                // MARK: - Button
                
                ZStack (alignment: .bottom) {
                    
                    VStack {
                        
                        HStack() {
                            Spacer()
                            Image(systemName: "x.circle.fill")
                                .font(.system(size: 24))
                                .opacity(0.1)
                                .onTapGesture {
                                    haptic.impactOccurred(intensity: 0.7)
                                    withAnimation {
                                        isExpanded = false
                                        buttonWidth = 200
                                        frameWidth = 200
                                        frameHeight = 56
                                        frameRadius = 28
                                        frameShadow = 0
                                    }
                                }
                        }
                        .opacity(isExpanded ? 1 : 0)
                        
                        Spacer()
                        
                        
                    }
                    .padding(24)
    
                    
                    Spacer()
                    
                    
                    ZStack {
                        
                        Rectangle()
                            .fill(Color.blue.opacity(isExpanded ? 0.3 : 1))
                            .frame(width: buttonWidth, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        
                        
                        Text(isExpanded ? "Nice!" : "Tap to expand")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isPressed ? 0.925 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isPressed = true
                            }
                            .onEnded { _ in
                                haptic.impactOccurred()
                                isPressed = false
                                withAnimation(.snappy) {
                                    isExpanded = true
                                    buttonWidth = UIScreen.main.bounds.width - 64
                                    frameWidth = UIScreen.main.bounds.width - 32
                                    frameShadow = 0.1
                                    frameHeight = 343
                                    frameRadius = 40
                                }
                            }
                    )
                }
                .frame(width: frameWidth)
            }
            .frame(width: frameWidth, height: frameHeight)
            .padding(.bottom, 16)
            .background(Color.white)
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
