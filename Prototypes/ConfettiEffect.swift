//
//  ConfettiEffect.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/18/24.
//

import SwiftUI
import UIKit

enum ParticleType {
    case plus
    case minus
}

struct PlusMinusParticle: View {
    let type: ParticleType
    let position: CGPoint
    @State private var opacity: Double = 1
    @State private var scale: Double = 1
    @State private var offset: CGSize = .zero
    
    var body: some View {
        Text(type == .plus ? "+1" : "-1")
            .font(.system(size: 60, weight: .bold))
            .foregroundStyle(.white)
            .position(position)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    scale = 1.5
                    offset = CGSize(width: 0, height: -100)
                }
            }
    }
}

struct NumberBurstParticle: View {
    let number: Int
    let position: CGPoint
    @State private var opacity: Double = 1
    @State private var scale: Double = 1
    @State private var offset: CGSize = .zero
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.white)
            .position(position)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = Double.random(in: 50...150)
                
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    scale = 0.5
                    offset = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                }
            }
    }
}
