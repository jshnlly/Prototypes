//
//  Counter.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/10/24.
//

import SwiftUI

struct Counter: View {
    @State var count: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var particles: [(id: UUID, position: CGPoint, number: Int)] = []
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private func addParticle(increment: Bool, at location: CGPoint) {
        let newCount = count + (increment ? 1 : -1)
        let id = UUID()
        particles.append((id: id, position: location, number: newCount))
        
        count = newCount
        haptic.impactOccurred()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Tap targets
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.green)
                        .contentShape(Rectangle())
                        .onTapGesture(coordinateSpace: .global) { location in
                            addParticle(increment: false, at: location)
                        }
                    
                    Rectangle()
                        .fill(Color.green)
                        .contentShape(Rectangle())
                        .onTapGesture(coordinateSpace: .global) { location in
                            addParticle(increment: true, at: location)
                        }
                }
                
                // Number display
                Text("\(count)")
                    .foregroundStyle(Color.white.opacity(1))
                    .padding(48)
                    .font(.system(size: 120))
                    .fontWeight(.bold)
                    .contentTransition(.numericText(value: Double(count)))
                    .animation(.snappy, value: count)
            }
            .background(Color.green)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        let verticalMovement = value.translation.height
                        let difference = verticalMovement - dragOffset
                        if abs(difference) >= 20 {
                            addParticle(increment: difference < 0, at: value.location)
                            dragOffset = verticalMovement
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                    }
            )
            // Add particles as an overlay
            .overlay {
                ForEach(particles, id: \.id) { particle in
                    ParticleEmitterView(position: particle.position, number: particle.number)
                        .id(particle.id)
                        .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    Counter()
}
