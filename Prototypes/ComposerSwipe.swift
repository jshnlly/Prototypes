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
    @State private var showChevron = false
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isFocused = false
                    }
                
                Spacer()
                
                // Position everything relative to screen edges
                ZStack(alignment: .leading) {
                    // Composer
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
                            .opacity(showChevron ? 1 : 0)
                            .scaleEffect(showChevron ? 1 : 0)
                        
                    }
                    .frame(width: composerWidth, height: 44)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .position(x: composerWidth/2 + 16, y: 22)  // Position from left edge
                    .onTapGesture {
                        if emojiOpen {
                            haptic.impactOccurred()
                            withAnimation(.spring()) {
                                emojiOpen = false
                                composerWidth = UIScreen.main.bounds.width * 0.8
                                isSwipingHorizontally = false
                                showChevron = false
                            }
                        }
                    }
                    
                    // Emojis
                    HStack(spacing: 8) {
                        Text("✌️").font(.system(size: 32))
                        Text("🤝").font(.system(size: 32))
                        Text("⚡️").font(.system(size: 32))
                        Text("👀").font(.system(size: 32))
                        Text("😎").font(.system(size: 32))
                        Text("🔥").font(.system(size: 32))
                        Text("💫").font(.system(size: 32))
                        Text("🎯").font(.system(size: 32))
                    }
                    .position(x: composerWidth + 200, y: 22)  // Position after composer
                }
                .frame(width: geometry.size.width, height: 44)
                .padding(.bottom, isTyping ? 12 : 64)
                .offset(x: 0, y: -keyboardHeight)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                isSwipingHorizontally = true
                                
                                withAnimation(.interactiveSpring()) {

                                        showChevron = false


                                   

                                    offsetX = value.translation.width
                                    
                                    if emojiOpen && value.translation.width > 0 {
                                        let dragPercentage = min(1, abs(value.translation.width) / 200)
                                        composerWidth = 44 + ((UIScreen.main.bounds.width * 0.8 - 44) * dragPercentage)
                                    } else if !emojiOpen && value.translation.width < 0 {
                                        let dragPercentage = min(1, abs(value.translation.width) / 200)
                                        let widthDifference = UIScreen.main.bounds.width * 0.8 - 44
                                        composerWidth = UIScreen.main.bounds.width * 0.8 - (widthDifference * dragPercentage)
                                    }
                                }
                            }
                        }
                        .onEnded { value in
                            haptic.impactOccurred()
                            isSwipingHorizontally = false
                            
                            if emojiOpen && value.translation.width > 50 {
                                withAnimation(.spring()) {
                                    emojiOpen = false
                                    composerWidth = UIScreen.main.bounds.width * 0.8
                                }
                            } else if !emojiOpen && value.translation.width < -50 {
                                withAnimation(.spring()) {
                                    emojiOpen = true
                                    composerWidth = 44
                                    showChevron = true  // Only show chevron after opening animation completes
                                }
                            } else {
                                withAnimation(.spring()) {
                                    composerWidth = emojiOpen ? 44 : UIScreen.main.bounds.width * 0.8
                                    showChevron = emojiOpen  // Match chevron to final state
                                }
                            }
                        }
                )
            }
            .onAppear {
                setupKeyboardNotifications()
                haptic.prepare()
            }
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            withAnimation(.interpolatingSpring(duration: duration)) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            withAnimation(.interpolatingSpring(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }
}

#Preview {
    ComposerSwipe()
}
