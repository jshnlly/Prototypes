//
//  NUXSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/14/24.
//

import SwiftUI

// First, let's create the button view
private struct TrayButton: View {
    let width: CGFloat
    let opacity: Double
    let text: String
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.blue.opacity(opacity))
                .frame(width: width, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 100))
            
            Text(text)
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
                    action()
                }
        )
    }
}

// Next, let's create the content view
private struct TrayContent: View {
    let isExpanded: Bool
    let isFullyExpanded: Bool
    let closeAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Dynamic tray")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                Spacer()
                Image(systemName: "x.circle.fill")
                    .font(.system(size: 24))
                    .opacity(0.1)
                    .onTapGesture(perform: closeAction)
            }
            .padding(.bottom, 16)
            
            TrayTextContent(isExpanded: isExpanded, isFullyExpanded: isFullyExpanded)
        }
        .padding(24)
        .frame(maxHeight: .infinity, alignment: .top)
        .opacity(isExpanded ? 1 : 0)
    }
}

// And the text content view
private struct TrayTextContent: View {
    let isExpanded: Bool
    let isFullyExpanded: Bool
    
    var body: some View {
        ZStack {
            // First text block
            VStack {
                Text("This is a recreation of a tray system originally designed by Family, the Ethereum wallet. It's a great example of how SwiftUI can be used to create animations.")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(isFullyExpanded ? 0 : 1)
            .scaleEffect(isExpanded ? 1 : 0.5)
            .offset(y: isExpanded ? -20 : 30)
            
            // Second text block (expanded state)
            VStack(spacing: 24) {
                Text("Step 2 jumps a bit higher than Step 1, we want to make the animation happen quickly")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Tapping the X here will close this step, but not the entire sheet. To close the entire sheet, tap the X twice!")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(isFullyExpanded ? 1 : 0)
            .scaleEffect(isFullyExpanded ? 1 : 0.5)
            .offset(y: isFullyExpanded ? 16 : 50)
        }
        .offset(y: isExpanded ? 0 : 100)
    }
}

// Finally, update the main view to use these components
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
    @Environment(\.colorScheme) var colorScheme
    
    private func expandToFirstStep() {
        withAnimation(FamilyTray.customAnimation) {
            isExpanded = true
            buttonWidth = UIScreen.main.bounds.width - 64
            frameWidth = UIScreen.main.bounds.width - 32
            frameShadow = 0.1
            frameHeight = 280
            frameRadius = 40
            buttonText = "One more time"
        }
    }
    
    private func expandToSecondStep() {
        withAnimation(FamilyTray.customAnimation) {
            isFullyExpanded = true
            frameHeight = 340
            buttonOpacity = 0.3
            buttonText = "Nice!"
        }
    }
    
    private func collapseToFirstStep() {
        withAnimation(FamilyTray.customAnimation) {
            buttonWidth = UIScreen.main.bounds.width - 64
            frameWidth = UIScreen.main.bounds.width - 32
            frameShadow = 0.1
            frameHeight = 280
            frameRadius = 40
            buttonOpacity = 1
            buttonText = "One more time"
            isFullyExpanded = false
        }
    }
    
    private func collapseFullyClosed() {
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
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .opacity(isExpanded ? 0.2 : 0)
                .ignoresSafeArea()
                .animation(FamilyTray.customAnimation, value: isExpanded)
            
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    // Content Layer
                    TrayContent(
                        isExpanded: isExpanded,
                        isFullyExpanded: isFullyExpanded,
                        closeAction: {
                            haptic.impactOccurred(intensity: 0.7)
                            if isFullyExpanded {
                                collapseToFirstStep()
                            } else {
                                collapseFullyClosed()
                            }
                        }
                    )
                    
                    // Button Layer
                    TrayButton(
                        width: buttonWidth,
                        opacity: buttonOpacity,
                        text: buttonText,
                        isPressed: $isPressed,
                        action: {
                            haptic.impactOccurred()
                            isPressed = false
                            
                            if !isExpanded {
                                expandToFirstStep()
                            } else {
                                expandToSecondStep()
                            }
                        }
                    )
                    .padding(.bottom, isExpanded ? 0 : 32)
                }
                .frame(width: frameWidth, height: frameHeight)
                .padding(.bottom, 24)
                .background(isExpanded ? (colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground)) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: frameRadius))
                .shadow(color: Color.secondary.opacity(0.15), radius: 12)
            }
            .padding(.bottom, 32)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                haptic.prepare()
            }
        }
    }
}

#Preview {
    FamilyTray()
}
