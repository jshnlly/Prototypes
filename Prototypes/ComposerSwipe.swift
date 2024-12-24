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
    
    func addItem(_ text: String, in bounds: CGRect) {
        let centerX = bounds.midX
        let centerY = bounds.midY
        let item = TextItem(text: text, position: CGPoint(x: centerX, y: centerY))
        items.append(item)
    }
}

struct DraggableText: View {
    @Binding var item: TextItem
    @GestureState private var dragState = CGSize.zero
    let bounds: CGRect
    
    var body: some View {
        Text(item.text)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding(20)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
            .position(
                x: min(max(bounds.minX, item.position.x + item.offset.width + dragState.width), bounds.maxX),
                y: min(max(bounds.minY, item.position.y + item.offset.height + dragState.height), bounds.maxY)
            )
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragState) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        let newX = item.position.x + item.offset.width + value.translation.width
                        let newY = item.position.y + item.offset.height + value.translation.height
                        
                        item.offset.width += value.translation.width
                        item.offset.height += value.translation.height
                        
                        // Constrain within bounds
                        if newX < bounds.minX {
                            item.offset.width = bounds.minX - item.position.x
                        }
                        if newX > bounds.maxX {
                            item.offset.width = bounds.maxX - item.position.x
                        }
                        if newY < bounds.minY {
                            item.offset.height = bounds.minY - item.position.y
                        }
                        if newY > bounds.maxY {
                            item.offset.height = bounds.maxY - item.position.y
                        }
                    }
            )
    }
}

struct CanvasView: View {
    @ObservedObject var model: CanvasModel
    let bounds: CGRect
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.05)
            
            ForEach($model.items) { $item in
                DraggableText(item: $item, bounds: bounds)
            }
        }
        .clipShape(Rectangle())
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
        let canvasBounds = CGRect(
            x: 16,
            y: 16,
            width: UIScreen.main.bounds.width - 32,
            height: UIScreen.main.bounds.height * 0.75 - 32
        )
        canvasModel.addItem(text, in: canvasBounds)
        withAnimation(.spring()) {
            text = ""
            isFocused = false
        }
        haptic.impactOccurred()
    }
    
    private func addEmojiToCanvas(_ emoji: String, geometry: GeometryProxy) {
        let canvasBounds = CGRect(
            x: 16,
            y: 16,
            width: geometry.size.width - 32,
            height: geometry.size.height * 0.75 - 32
        )
        canvasModel.addItem(emoji, in: canvasBounds)
        haptic.impactOccurred()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Canvas area
                CanvasView(model: canvasModel, bounds: CGRect(
                    x: 16,
                    y: 16,
                    width: geometry.size.width - 32,
                    height: geometry.size.height * 0.75 - 32
                ))
                .frame(height: geometry.size.height * 0.75)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .padding(.top)
                
                // Composer area
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
                            .offset(x: 20)
                            .onTapGesture {
                                haptic.impactOccurred()
                                withAnimation(.spring()) {
                                    emojiOpen = false
                                    composerWidth = hasText ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8
                                    isSwipingHorizontally = false
                                    showChevron = false
                                }
                            }
                        
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
                    .position(x: composerWidth/2 + 16, y: 22)
                    
                    // Emojis
                    HStack(spacing: 8) {
                        Text("✌️").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("✌️", geometry: geometry)
                            }
                        Text("🤝").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("🤝", geometry: geometry)
                            }
                        Text("⚡️").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("⚡️", geometry: geometry)
                            }
                        Text("👀").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("👀", geometry: geometry)
                            }
                        Text("😎").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("😎", geometry: geometry)
                            }
                        Text("🔥").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("🔥", geometry: geometry)
                            }
                        Text("💫").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("💫", geometry: geometry)
                            }
                        Text("🎯").font(.system(size: 32))
                            .onTapGesture {
                                addEmojiToCanvas("🎯", geometry: geometry)
                            }
                    }
                    .position(x: composerWidth + 200, y: 22)
                }
                .frame(height: 44)
                .padding(.vertical)
                .padding(.bottom, isTyping ? 0 : geometry.safeAreaInsets.bottom + 12)
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
            .offset(y: -keyboardHeight)
        }
        .padding(.bottom, isTyping ? 4 : 16)
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
