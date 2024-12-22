//
//  ComposerSwipe.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/21/24.
//

import SwiftUI

struct ComposerSwipe: View {
    
    @State var text: String = ""
    @State var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var composerWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    @FocusState private var isFocused: Bool
    @State var emojiOpen = false
    @State private var isSwipingHorizontally = false
    
    // Add haptic generators
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            
            Spacer()
            
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ZStack {
                            
                            TextField("Message", text: $text, onEditingChanged: { editing in
                                withAnimation(.spring()) {
                                    isTyping = editing
                                }
                            })
                            .focused($isFocused)
                            .padding(.leading, 20)
                            .disabled(emojiOpen || isSwipingHorizontally)
                            .opacity(emojiOpen ? 0 : 1)
                            
                            
                            
                            Image(systemName: "chevron.left")
                                .opacity(emojiOpen ? 1 : 0)
                                .scaleEffect(emojiOpen ? 1 : 0)
                            
                            
                        }
                        .frame(width: composerWidth, height: 44)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .onTapGesture {
                            if emojiOpen {
                                haptic.impactOccurred()  // Add haptic for back tap
                                withAnimation(.spring()) {
                                    emojiOpen = false
                                    composerWidth = UIScreen.main.bounds.width * 0.8  // Reset to full width
                                    isSwipingHorizontally = false
                                }
                            }
                        }
                        
                        Text("✌️")
                            .font(.system(size: 32))
                        Text("🤝")
                            .font(.system(size: 32))
                        Text("⚡️")
                            .font(.system(size: 32))
                        Text("👀")
                            .font(.system(size: 32))
                        Text("😎")
                            .font(.system(size: 32))
                    }
                    .padding(.trailing, 16)
                }
                .scrollDisabled(!emojiOpen)
            }
            .padding(.leading)
            .padding(.bottom, isTyping ? 12 : 64)
            .offset(x: 0, y: -keyboardHeight)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Determine if this is primarily a horizontal or vertical gesture
                        let isHorizontalGesture = abs(value.translation.width) > abs(value.translation.height)
                        
                        // Only handle keyboard dismissal for vertical gestures
                        if !isHorizontalGesture && value.translation.height > 50 && keyboardHeight > 0 {
                            isFocused = false
                        }
                        
                        // Handle horizontal swipe for emoji
                        if isHorizontalGesture {
                            isSwipingHorizontally = true
                            withAnimation(.interactiveSpring()) {
                                offsetX = value.translation.width
                                emojiOpen = false
                                
                                let dragPercentage = min(1, abs(value.translation.width) / 200)
                                let widthDifference = UIScreen.main.bounds.width * 0.8 - 44
                                composerWidth = UIScreen.main.bounds.width * 0.8 - (widthDifference * dragPercentage)
                            }
                        }
                    }
                    .onEnded { value in
                        isSwipingHorizontally = false
                        haptic.impactOccurred()
                        withAnimation(.spring()) {
                            offsetX = 0
                            composerWidth = 44
                            emojiOpen = true
                        }
                    }
            )
        }
        .onAppear {
            setupKeyboardNotifications()
            haptic.prepare()  // Prepare the haptic generator
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            withAnimation(.spring()) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.spring()) {
                keyboardHeight = 0
            }
        }
    }
}

#Preview {
    ComposerSwipe()
}
