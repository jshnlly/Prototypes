//
//  Counter.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/10/24.
//

import SwiftUI

struct Counter: View {
    @State var count: Int = 0
    @State var hasDecimal: Bool = false  // Track decimal state
    @State private var dragOffset: CGFloat = 0
    @State private var plusMinusParticles: [(id: UUID, position: CGPoint, type: ParticleType)] = []
    @State private var numberBurst: [(id: UUID, position: CGPoint, number: Int)] = []
    @State private var isNumberVisible = true
    @State private var isNumberPressed = false
    @State private var shakeAmount: CGFloat = 0
    @State private var rotationAmount: Double = 0
    let haptic = UIImpactFeedbackGenerator(style: .light)
    let errorHaptic = UINotificationFeedbackGenerator()
    
    // Number pad layout
    let keypad = [
        ["9", "8", "7"],
        ["6", "5", "4"],
        ["3", "2", "1"],
        [".", "0", "⌫"]
    ]
    
    private func addPlusMinusParticle(increment: Bool, at location: CGPoint) {
        let id = UUID()
        let type: ParticleType = increment ? .plus : .minus
        plusMinusParticles.append((id: id, position: location, type: type))
        
        count += increment ? 1 : -1
        haptic.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            plusMinusParticles.removeAll { $0.id == id }
        }
    }
    
    private func numberTapped(at location: CGPoint) {
        withAnimation(.easeOut(duration: 0.2)) {
            isNumberVisible = true
            isNumberPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            haptic.impactOccurred()
            
            // Calculate center position relative to the counter section
            let screenHeight = UIScreen.main.bounds.height
            let counterSectionHeight = screenHeight * 0.4
            let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
            
            let centerPosition = CGPoint(
                x: UIScreen.main.bounds.width / 2,
                y: safeAreaTop + (counterSectionHeight / 2) + 60  // Added 20pt offset to move down
            )
            
            // Create particles from center
            for _ in 0..<10 {
                let id = UUID()
                numberBurst.append((id: id, position: centerPosition, number: count))
            }
            
            withAnimation(.spring) {
                count = 0
                isNumberPressed = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                numberBurst.removeAll()
            }
        }
    }
    
    private func handleNumberPadInput(_ key: String) {
        switch key {
        case "0"..."9":
            if hasDecimal {
                // If decimal is active, only allow two digits after decimal
                let currentCents = count % 100
                if currentCents < 10 {
                    let newValue = (count * 10) + (Int(key) ?? 0)
                    if newValue <= 99999 {
                        haptic.impactOccurred()
                        count = newValue
                    } else {
                        withAnimation(.default) {
                            shakeAmount = 10
                            rotationAmount = 2
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.default) {
                                    shakeAmount = -10
                                    rotationAmount = -2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.default) {
                                            shakeAmount = 0
                                            rotationAmount = 0
                                        }
                                    }
                                }
                            }
                        }
                        errorHaptic.notificationOccurred(.error)
                    }
                }
            } else {
                // Normal whole number input
                let newValue = (count * 10) + (Int(key) ?? 0)
                if newValue <= 99999 {
                    haptic.impactOccurred()
                    count = newValue
                } else {
                    withAnimation(.default) {
                        shakeAmount = 10
                        rotationAmount = 2
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.default) {
                                shakeAmount = -10
                                rotationAmount = -2
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.default) {
                                        shakeAmount = 0
                                        rotationAmount = 0
                                    }
                                }
                            }
                        }
                    }
                    errorHaptic.notificationOccurred(.error)
                }
            }
        case "⌫":
            haptic.impactOccurred()
            if hasDecimal && count % 100 == 0 {
                // If at .00, remove decimal
                hasDecimal = false
            }
            count = count / 10
        case ".":
            haptic.impactOccurred()
            if !hasDecimal {
                hasDecimal = true
                count = count * 100  // Move existing number to dollars position
            }
        default:
            break
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if hasDecimal {
            // Format as dollars and cents
            let dollars = number / 100
            let cents = number % 100
            return "\(formatWholeNumber(dollars)).\(String(format: "%02d", cents))"
        } else {
            return formatWholeNumber(number)
        }
    }
    
    private func formatWholeNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    var body: some View {
        ZStack {
            // Full screen background
            Color.green
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Top section with counter
                ZStack {
                    // Tap targets
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)  // Changed to clear since we have the green background
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .global) { location in
                                addPlusMinusParticle(increment: false, at: location)
                            }
                        
                        Rectangle()
                            .fill(Color.clear)  // Changed to clear
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .global) { location in
                                addPlusMinusParticle(increment: true, at: location)
                            }
                    }
                    
                    // Number display
                    HStack(spacing: 0) {
                        Text("$")
                            .foregroundStyle(Color.white.opacity(1))
                            .font(.system(size: String(count).count >= 4 ? 80 : 120))
                            .fontWeight(.bold)
                        
                        Text(formatNumber(count))
                            .foregroundStyle(Color.white.opacity(1))
                            .font(.system(size: String(count).count >= 4 ? 80 : 120))
                            .fontWeight(.bold)
                            .contentTransition(.numericText(value: Double(count)))
                            .animation(.snappy, value: count)
                    }
                    .offset(x: shakeAmount)
                    .rotationEffect(.degrees(rotationAmount))
                    .scaleEffect(isNumberPressed ? 0.3 : 1)
                    .animation(.spring(response: 0.3), value: isNumberPressed)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { _ in
                                isNumberPressed = true
                            }
                            .onEnded { value in
                                isNumberPressed = false
                                numberTapped(at: value.location)
                            }
                    )
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.4)  // 40% of screen height
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            let verticalMovement = value.translation.height
                            let difference = verticalMovement - dragOffset
                            if abs(difference) >= 20 {
                                count += difference < 0 ? 1 : -1
                                haptic.impactOccurred()
                                dragOffset = verticalMovement
                            }
                        }
                        .onEnded { _ in
                            dragOffset = 0
                        }
                )
                
                // Number pad
                VStack(spacing: 0.5) {
                    ForEach(keypad, id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(row, id: \.self) { key in
                                Button(action: {
                                    handleNumberPadInput(key)
                                }) {
                                    if key == "⌫" {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 24, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 80)
                                    } else {
                                        Text(key)
                                            .font(.system(size: 32, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 80)
                                    }
                                }
                                .buttonStyle(NumberPadButtonStyle())
                            }
                        }
                    }
                }
                .foregroundStyle(.white)
                .padding(.top)  // Add some space between counter and keypad
            }
            
            // Particle overlays
            ForEach(plusMinusParticles, id: \.id) { particle in
                PlusMinusParticle(type: particle.type, position: particle.position)
                    .id(particle.id)
            }
            
            ForEach(numberBurst, id: \.id) { particle in
                NumberBurstParticle(number: particle.number, position: particle.position)
                    .id(particle.id)
            }
        }
        .onAppear {
            haptic.prepare()
            errorHaptic.prepare()
        }
    }
}

struct NumberPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.875 : 1)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    Counter()
}
