//
//  ThingsListCell.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/3/24.
//

import SwiftUI
import UIKit

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
        if dragOffset.width < -44 {  // Adding a small threshold
            isLeftActive = true
            isRightActive = false
            
        } else if dragOffset.width > 44 {  // Adding a small threshold
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
        ZStack {
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
                    
                    Group {
                        Button("Done") {
                            unSelect()
                        }
                        .padding(.leading, 12)
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .bold()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .animation(.spring())
                    .offset(y: isSelected || isChanging ? 0 : -120)
                    .opacity(isSelected || isChanging ? 1 : 0)
                }
                .padding(16)
                
                ZStack {
                    ZStack {
                        
                        HStack {
                            ZStack (alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.yellow)
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 12)
                            }
                            .frame(width: (UIScreen.main.bounds.width / 2) - 12)
                            
                            ZStack (alignment: .trailing) {
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
                        .padding(.leading, 0.5)
                        .padding(.trailing, 0.5)
                        .frame(height: 42.5)
                        
                        
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
                            
                            
                            
//                            TextField("New To-Do", text: $text)
//                                .foregroundColor(Color.black)
//                                .font(.title3)
//                                .padding(.leading, 4)
                            
                        }
                        .padding(10)
                        .background(isPressed || isSelected || isChanging ? Color.lightBlue : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.1), lineWidth: isPressed ? 1 : 0)
                        )
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
                                .simultaneously(
                                    with: TapGesture()
                                        .onEnded {
                                            
                                        }
                                )
                        )
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.1), lineWidth: isPressed ? 1 : 0)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(10)
                
                
                
                Spacer()
            }
        }
    }
}


#Preview {
    ThingsListCell()
}
