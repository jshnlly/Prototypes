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
    @State private var plusMinusParticles: [(id: UUID, position: CGPoint, type: ParticleType)] = []
    @State private var numberBurst: [(id: UUID, position: CGPoint, number: Int)] = []
    @State private var isNumberVisible = true
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    private func addPlusMinusParticle(increment: Bool, at location: CGPoint) {
        let id = UUID()
        let type: ParticleType = increment ? .plus : .minus
        plusMinusParticles.append((id: id, position: location, type: type))
        
        count += increment ? 1 : -1
        haptic.impactOccurred()
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            plusMinusParticles.removeAll { $0.id == id }
        }
    }
    
    private func numberTapped(at location: CGPoint) {
        isNumberVisible = false
        haptic.impactOccurred()
        
        // Add multiple number particles
        for _ in 0..<10 {
            let id = UUID()
            numberBurst.append((id: id, position: location, number: count))
        }
        
        // Remove particles and restore number
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            numberBurst.removeAll()
            withAnimation(.spring) {
                isNumberVisible = true
            }
        }
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
                            addPlusMinusParticle(increment: false, at: location)
                        }
                    
                    Rectangle()
                        .fill(Color.green)
                        .contentShape(Rectangle())
                        .onTapGesture(coordinateSpace: .global) { location in
                            addPlusMinusParticle(increment: true, at: location)
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
                    .opacity(isNumberVisible ? 1 : 0)
                    .onTapGesture(coordinateSpace: .global) { location in
                        numberTapped(at: location)
                    }
            }
            .background(Color.green)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        let verticalMovement = value.translation.height
                        let difference = verticalMovement - dragOffset
                        if abs(difference) >= 20 {
                            addPlusMinusParticle(increment: difference < 0, at: value.location)
                            dragOffset = verticalMovement
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                    }
            )
            // Add particles as overlays
            .overlay {
                // Plus/Minus particles
                ForEach(plusMinusParticles, id: \.id) { particle in
                    PlusMinusParticle(type: particle.type, position: particle.position)
                        .id(particle.id)
                }
                
                // Number burst particles
                ForEach(numberBurst, id: \.id) { particle in
                    NumberBurstParticle(number: particle.number, position: particle.position)
                        .id(particle.id)
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
