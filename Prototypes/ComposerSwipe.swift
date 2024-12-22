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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            
            Spacer()
            
            HStack(spacing: 8) {
                ZStack {
                    TextField("Message", text: $text, onEditingChanged: { editing in
                        withAnimation(.spring()) {
                            isTyping = editing
                        }
                    })
                    .focused($isFocused)
                    .padding(.leading, 20)
                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 44)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
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
            }
            .padding(.leading)
            .padding(.bottom, isTyping ? 12 : 64)
            .offset(y: -keyboardHeight)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 50 && keyboardHeight > 0 {
                        isFocused = false
                    }
                }
        )
        .onAppear {
            setupKeyboardNotifications()
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
