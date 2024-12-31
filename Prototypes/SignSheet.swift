//
//  SignSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/27/24.
//

import SwiftUI

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
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
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
                        }
                        .frame(width: isExpanded ? UIScreen.main.bounds.width * 0.38 : UIScreen.main.bounds.width * 0.8, height: 56)
                        .background(Color.primary)
                        .opacity(isExpanded && !isSigned ? 0.5 : 1)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(SignButtonStyle())
                }
                .padding(.bottom, 48)
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
