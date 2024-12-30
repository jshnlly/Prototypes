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
    
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Button {
                    haptic.impactOccurred()
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.outline")
                            .foregroundStyle(Color(uiColor: .systemBackground))
                        Text("Sign here")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(uiColor: .systemBackground))
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 56)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(SignButtonStyle())
            }
            .padding(.bottom, 48)
        }
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    SignSheet()
}
