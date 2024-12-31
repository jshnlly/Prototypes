//
//  SignSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/27/24.
//

import SwiftUI

struct DrawingCanvas: View {
    @State private var lines: [Line] = []
    @State private var currentLine: Line?
    
    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }
            if let line = currentLine {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let point = value.location
                    if currentLine == nil {
                        currentLine = Line(points: [point])
                    } else {
                        currentLine?.points.append(point)
                    }
                }
                .onEnded { _ in
                    if let line = currentLine {
                        lines.append(line)
                        currentLine = nil
                    }
                }
        )
    }
}

struct Line {
    var points: [CGPoint]
}

struct SignButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.925 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SignSheet: View {
    @State var openSheet: Bool = false
    @State var isSigned: Bool = false
    @State private var isExpanded: Bool = false
    @State var sheetHeight: CGFloat = 376
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack(alignment: .bottom) {
                    // Background Layer
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                        .frame(width: isExpanded ? UIScreen.main.bounds.width - 32 : UIScreen.main.bounds.width * 0.8, height: isExpanded ? sheetHeight : 56)
                        .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 32 : 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 12)
                    
                    // Buttons Layer
                    VStack (alignment: .center, spacing: 24) {
                        
                        VStack(alignment: .center, spacing: 24) {
                                Text("Sign here")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.primary.opacity(1))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                ZStack{
                                    // Background rectangle first (bottom layer)
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                                        )
                                        .frame(width: UIScreen.main.bounds.width * 0.38 * 2 + 12, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Drawing canvas on top (moved up in ZStack order)
                                    DrawingCanvas()
                                        .frame(width: UIScreen.main.bounds.width * 0.38 * 2 + 12, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    // Divider line
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.2))
                                        .frame(width: UIScreen.main.bounds.width * 0.38 * 2 - 24, height: 1)
                                        .offset(y: 72)
                                }
                            }
                            .padding(.horizontal, 12)
                            .scaleEffect(isExpanded ? 1 : 0.875)
                            .offset(y: isExpanded ? 0 : 200)
                            .opacity(isExpanded ? 1 : 0)
                        
                        HStack(spacing: 12) {
                            // Cancel Button
                            Button {
                                haptic.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.primary)
                                }
                                .frame(width: isExpanded ? UIScreen.main.bounds.width * 0.38 : 0, height: 56)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .buttonStyle(SignButtonStyle())
                            .opacity(isExpanded ? 1 : 0)
                            .scaleEffect(isExpanded ? 1 : 0.8)
                            
                            // Sign/Confirm Button
                            Button {
                                haptic.impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isExpanded = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "pencil.and.outline")
                                        .foregroundStyle(Color(uiColor: .systemBackground))
                                        .opacity(isExpanded ? 0 : 1)
                                    Text(isExpanded && !isSigned ? "Confirm" : "Sign here")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color(uiColor: .systemBackground))
                                        .offset(x: isExpanded ? -12 : 0)
                                        .animation(nil, value: isExpanded)
                                }
                                .frame(width: isExpanded ? UIScreen.main.bounds.width * 0.38 : UIScreen.main.bounds.width * 0.8, height: 56)
                                .background(Color.primary)
                                .opacity(isExpanded && !isSigned ? 0.5 : 1)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .offset(x: isExpanded ? 0 : -6)
                            }
                            .buttonStyle(SignButtonStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, isExpanded ? 24 : 0)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, isExpanded ? 40 : 48)
            }
        }
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    SignSheet()
}
