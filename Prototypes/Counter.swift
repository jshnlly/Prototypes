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
    
    private func handleTap(_ increment: Bool, location: CGPoint, in geometry: GeometryProxy) {
        let newCount = count + (increment ? 1 : -1)
        
        // Convert tap location to the correct coordinate space
        let tapLocation = CGPoint(
            x: location.x,
            y: location.y + geometry.safeAreaInsets.top
        )
        
        // Add new particle with the target number
        let id = UUID()
        particles.append((id: id, position: tapLocation, number: newCount))
        
        // Clean up this particle after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            particles.removeAll { $0.id == id }
        }
        
        // Update count immediately
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
                            handleTap(false, location: location, in: geometry)
                        }
                    Rectangle()
                        .fill(Color.green)
                        .contentShape(Rectangle())
                        .onTapGesture(coordinateSpace: .global) { location in
                            handleTap(true, location: location, in: geometry)
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
                
                // Particle effects - now using the stored number
                ForEach(particles, id: \.id) { particle in
                    ParticleEmitterView(position: particle.position, number: particle.number)
                        .id(particle.id)
                }
            }
            .background(Color.green)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        let verticalMovement = value.translation.height
                        let difference = verticalMovement - dragOffset
                        if abs(difference) >= 20 {
                            handleTap(difference < 0, location: value.location, in: geometry)
                            dragOffset = verticalMovement
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                    }
            )
        }
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    Counter()
}
