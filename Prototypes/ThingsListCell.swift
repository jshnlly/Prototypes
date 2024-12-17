//
//  ThingsListCell.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/3/24.
//

import SwiftUI
import UIKit

struct ActionButtons: View {
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow)
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.white)
                    .padding(.leading, 12)
            }
            .frame(width: (UIScreen.main.bounds.width / 2) - 12)
            
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                Image(systemName: "list.bullet")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(Color.white)
                    .padding(.trailing, 12)
            }
            .frame(width: (UIScreen.main.bounds.width / 2) - 12)
        }
        .padding(.horizontal, 0.5)
        .frame(height: 42.5)
    }
}

struct TodoCell: View {
    let isPressed: Bool
    let isSelected: Bool
    let isChanging: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "square")
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(Color.gray)
            
            Text("New To-Do")
                .foregroundColor(Color.gray)
                .font(.title3)
                .padding(.leading, 4)
            
            Spacer()
            
            Image(systemName: "circle.circle")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(Color.blue)
                .opacity(isChanging || isSelected ? 1 : 0)
        }
        .padding(10)
        .background(isPressed || isSelected || isChanging ? Color.lightBlue : Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ThingsListCell: View {
    
    @State var text: String = ""
    @State var isPressed: Bool = false
    @State var dragOffset: CGSize = .zero
    let maxDistance: CGFloat = 44
    @State var isLeftActive: Bool = false
    @State var isRightActive: Bool = false
    @State var isSelected: Bool = false
    @State var isChanging: Bool = false
    
    private func updateDragState() {
        if dragOffset.width < -44 {
            isLeftActive = true
            isRightActive = false
        } else if dragOffset.width > 44 {
            isRightActive = true
            isLeftActive = false
        } else {
            isLeftActive = false
            isRightActive = false
        }
    }
    
    private func unSelect() {
        isSelected = false
        isChanging = false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.yellow)
                
                Text("Today")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    unSelect()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .bold()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .animation(.spring())
                .offset(y: isSelected || isChanging ? 0 : -120)
                .opacity(isSelected || isChanging ? 1 : 0)
            }
            .padding(16)
            
            ZStack {
                ActionButtons()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(isPressed && !isLeftActive && !isRightActive ? 0.2 : 0))
                    )
                    .animation(.smooth())
                
                TodoCell(isPressed: isPressed, isSelected: isSelected, isChanging: isChanging)
                    .offset(x: min(max(dragOffset.width, -maxDistance), maxDistance))
                    .animation(.spring())
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation
                                isPressed = true
                                updateDragState()
                            }
                            .onEnded { _ in
                                if isLeftActive || isRightActive {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.prepare()
                                    generator.impactOccurred()
                                }
                                
                                if isLeftActive {
                                    isChanging = true
                                }
                                
                                if isRightActive {
                                    isSelected = true
                                }
                                
                                dragOffset = .zero
                                isPressed = false
                            }
                    )
            }
            .padding(10)
            
            Spacer()
        }
    }
}

#Preview {
    ThingsListCell()
}
