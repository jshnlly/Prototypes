//
//  ComposerSwipe.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/21/24.
//

import SwiftUI

struct TextItem: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint
    var offset: CGSize = .zero
}

class CanvasModel: ObservableObject {
    @Published var items: [TextItem] = []
    
    func addItem(_ text: String) {
        let centerPosition = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        let item = TextItem(text: text, position: centerPosition)
        items.append(item)
    }
}

struct DraggableText: View {
    @Binding var item: TextItem
    @GestureState private var dragState = CGSize.zero
    
    var body: some View {
        Text(item.text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding()
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
            .position(x: item.position.x + item.offset.width + dragState.width,
                     y: item.position.y + item.offset.height + dragState.height)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragState) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        item.offset.width += value.translation.width
                        item.offset.height += value.translation.height
                    }
            )
    }
}

struct CanvasView: View {
    @ObservedObject var model: CanvasModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                ForEach($model.items) { $item in
                    DraggableText(item: $item)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ComposerSwipe: View {
    @StateObject private var canvasModel = CanvasModel()
    @State var text: String = ""
    @State var isTyping: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var composerWidth: CGFloat = UIScreen.main.bounds.width * 0.8
    @FocusState private var isFocused: Bool
    @State var emojiOpen = false
    @State private var isSwipingHorizontally = false
    @State private var showChevron = false
    
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    private func sendMessage() {
        guard hasText else { return }
        canvasModel.addItem(text)
        withAnimation(.spring()) {
            text = ""
            isFocused = false
        }
        haptic.impactOccurred()
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear // Background to ensure full geometry
                .overlay {
                    CanvasView(model: canvasModel)
                }
                .overlay(alignment: .bottom) {
                    VStack(spacing: 0) {
                        // Position everything relative to screen edges
                        ZStack(alignment: .leading) {
                            // Composer
                            ZStack (alignment: .leading) {
                                TextField("Message", text: Binding(
                                    get: { text },
                                    set: { newValue in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            text = newValue
                                            if hasText {
                                                composerWidth = UIScreen.main.bounds.width - 32
                                            } else {
                                                composerWidth = UIScreen.main.bounds.width * 0.8
                                            }
                                        }
                                    }
                                ), onEditingChanged: { editing in
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
                                    .offset(x: 16)
                                
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Image(systemName: "arrow.up")
                                            .foregroundStyle(Color.white)
                                    }
                                    .frame(width: 36, height: 36)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .opacity(hasText && !emojiOpen ? 1 : 0)
                                    .scaleEffect(hasText && !emojiOpen ? 1 : 0)
                                    .onTapGesture {
                                        sendMessage()
                                    }
                                }
                                .padding(.trailing, 4)
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
                                        composerWidth = hasText ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8
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
                                            
                                            if emojiOpen && value.translation.width > 0 {
                                                let dragPercentage = min(1, abs(value.translation.width) / 200)
                                                composerWidth = 44 + ((UIScreen.main.bounds.width * 0.8 - 44) * dragPercentage)
                                            } else if !emojiOpen && value.translation.width < 0 {
                                                let dragPercentage = min(1, abs(value.translation.width) / 200)
                                                let baseWidth = hasText ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8
                                                composerWidth = baseWidth - ((baseWidth - 44) * dragPercentage)
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
                                            composerWidth = hasText ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8
                                        }
                                    } else if !emojiOpen && value.translation.width < -50 {
                                        withAnimation(.spring()) {
                                            emojiOpen = true
                                            composerWidth = 44
                                            showChevron = true
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            composerWidth = emojiOpen ? 44 : (hasText ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8)
                                            showChevron = emojiOpen
                                        }
                                    }
                                }
                        )
                    }
                }
                .ignoresSafeArea()
        }
        .onAppear {
            setupKeyboardNotifications()
            haptic.prepare()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                keyboardHeight = 0
            }
        }
    }
}

#Preview {
    ComposerSwipe()
}
