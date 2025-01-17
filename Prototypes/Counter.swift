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
    @State private var hasTriggeredHorizontalGesture = false
    @State private var showNumberPad: Bool = false  // Add this state
    let haptic = UIImpactFeedbackGenerator(style: .light)
    let errorHaptic = UINotificationFeedbackGenerator()
    
    // Number pad layout
    let keypad = [
        ["9", "8", "7"],
        ["6", "5", "4"],
        ["3", "2", "1"],
        [".", "0", "⌫"]
    ]
    
    private func calculateCenterPosition() -> CGPoint {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        
        // When number pad is visible, center in the top section
        // When hidden, center in the whole screen
        let centerY = showNumberPad ? 
            safeAreaTop + (screenHeight * 0.4 / 2) :  // Center in top section
            (screenHeight * 0.45)  // Position at about 45% from the top when no number pad
        
        return CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: centerY
        )
    }
    
    private func addPlusMinusParticle(increment: Bool, at location: CGPoint) {
        let id = UUID()
        let type: ParticleType = increment ? .plus : .minus
        plusMinusParticles.append((id: id, position: location, type: type))
        
        if hasDecimal {
            // Handle decimal numbers (count represents cents * 100)
            if increment {
                count += 1
            } else {
                // When decrementing with decimal
                if count == 0 {
                    // At 0.00, going to -0.01
                    count = -1
                } else if count == -99 {
                    // At -0.99, going to -1.00
                    count = -100
                } else {
                    count -= 1
                }
            }
        } else {
            // For whole numbers
            let newValue = count + (increment ? 1 : -1)
            count = newValue
        }
        
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
            
            // Create particles from center
            for _ in 0..<10 {
                let id = UUID()
                numberBurst.append((id: id, position: calculateCenterPosition(), number: count))
            }
            
            withAnimation(.spring) {
                count = 0
                hasDecimal = false  // Reset decimal state
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
                    // Just add the digit to cents without multiplying the whole number
                    let dollars = count / 100
                    let newCents = (currentCents * 10) + (Int(key) ?? 0)
                    count = (dollars * 100) + newCents
                    haptic.impactOccurred()
                }
            } else {
                // Normal whole number input
                let newValue = (count * 10) + (Int(key) ?? 0)
                if newValue <= 99999 {
                    haptic.impactOccurred()
                    count = newValue
                } else {
                    withAnimation(.default) {
                        shakeAmount = 20
                        rotationAmount = 5
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.default) {
                                shakeAmount = -20
                                rotationAmount = -5
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.default) {
                                        shakeAmount = 0
                                        rotationAmount = 0
                                    }
                                }
                            }
                        }
                    }
                    errorHaptic.notificationOccurred(.warning)
                }
            }
        case "⌫":
            haptic.impactOccurred()
            if hasDecimal {
                let dollars = count / 100
                let cents = count % 100
                
                if cents >= 10 {
                    // Remove rightmost digit but keep decimal position
                    let newCents = cents / 10
                    count = (dollars * 100) + newCents
                } else {
                    // If only one digit after decimal, remove decimal
                    hasDecimal = false
                    count = dollars
                }
            } else {
                count = count / 10
            }
        case ".":
            haptic.impactOccurred()
            if !hasDecimal {
                hasDecimal = true
                count = count * 100  // Move current number to dollars position
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
            
            // Return differently formatted strings based on cents
            if cents == 0 {
                // Use AttributedString to make .00 more transparent
                let dollarsStr = formatWholeNumber(dollars)
                return dollarsStr  // We'll handle the decimal part in the view
            } else {
                return "\(formatWholeNumber(dollars)).\(String(format: "%02d", cents))"
            }
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
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .global) { location in
                                // Only allow negative tap if we're not at 0.00
                                if !(hasDecimal && count == 0) {
                                    addPlusMinusParticle(increment: false, at: location)
                                }
                            }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .global) { location in
                                addPlusMinusParticle(increment: true, at: location)
                            }
                    }
                    
                    // Number display
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Text("$")
                                .foregroundStyle(Color.white.opacity(1))
                                .font(.system(size: String(count).count >= 4 ? 80 : 120))
                                .fontWeight(.bold)
                            
                            if hasDecimal && count % 100 == 0 {
                                // Show faded decimal when .00
                                (Text(formatNumber(count))
                                    .foregroundStyle(Color.white.opacity(1))
                                    .font(.system(size: String(count).count >= 4 ? 80 : 120))
                                    .fontWeight(.bold) +
                                Text(".00")
                                    .foregroundStyle(Color.white.opacity(0.2))
                                    .font(.system(size: String(count).count >= 4 ? 80 : 120))
                                    .fontWeight(.bold))
                                    .onTapGesture { location in
                                        numberTapped(at: location)
                                    }
                            } else {
                                // Normal display
                                Text(formatNumber(count))
                                    .foregroundStyle(Color.white.opacity(1))
                                    .font(.system(size: String(count).count >= 4 ? 80 : 120))
                                    .fontWeight(.bold)
                                    .onTapGesture { location in
                                        numberTapped(at: location)
                                    }
                            }
                        }
                        .contentTransition(.numericText(value: Double(count)))
                        .animation(.snappy, value: count)
                        .offset(x: shakeAmount)
                        .rotationEffect(.degrees(rotationAmount))
                        .scaleEffect(isNumberPressed ? 0.3 : 1)
                        .animation(.spring(response: 0.3), value: isNumberPressed)
                        
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.5))
                            .offset(y: showNumberPad ? 120 : 300)
                            .opacity(showNumberPad ? 0 : 1)
                            .padding(24)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showNumberPad.toggle()
                                    haptic.impactOccurred()
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.4)
                
                // Number pad
                if showNumberPad {
                    VStack(spacing: 0.5) {
                        ForEach(keypad, id: \.self) { row in
                            HStack(spacing: 1) {
                                ForEach(row, id: \.self) { key in
                                    Button(action: {
                                        handleNumberPadInput(key)
                                    }) {
                                        // Container for the entire button area
                                        ZStack {
                                            // Button content
                                            if key == "⌫" {
                                                Image(systemName: "chevron.left")
                                                    .font(.system(size: 24, weight: .medium))
                                                    .opacity(0.5)
                                            } else if key == "." {
                                                Text(key)
                                                    .font(.system(size: 32, weight: .medium))
                                                    .opacity(0.5)
                                            } else {
                                                Text(key)
                                                    .font(.system(size: 32, weight: .medium))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 80)
                                        .contentShape(Rectangle())  // Make entire area tappable
                                    }
                                    .buttonStyle(NumberPadButtonStyle())
                                }
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.top)  // Add some space between counter and keypad
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 50 {
                                    withAnimation(.spring()) {
                                        showNumberPad = false
                                        haptic.impactOccurred()
                                    }
                                }
                            }
                    )
                }
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
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    // Determine if this is a horizontal or vertical gesture
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        // Horizontal gesture
                        if abs(horizontalAmount) >= 20 && !hasTriggeredHorizontalGesture {
                            hasTriggeredHorizontalGesture = true  // Prevent multiple triggers
                            
                            if horizontalAmount > 0 {
                                // Swipe right - add decimal if not present
                                if !hasDecimal {
                                    haptic.impactOccurred()
                                    hasDecimal = true
                                    count = count * 100
                                }
                            } else {
                                // Swipe left - act like backspace
                                haptic.impactOccurred()
                                handleNumberPadInput("⌫")  // Use the same handler as the backspace button
                            }
                        }
                    } else {
                        // Vertical gesture
                        let difference = verticalAmount - dragOffset
                        if abs(difference) >= 20 {
                            if hasDecimal {
                                let dollars = count / 100
                                let cents = count % 100
                                
                                // Only prevent negative if dollars is 0
                                if dollars == 0 && difference > 0 && cents == 0 {
                                    // Don't allow negative when at $0.00
                                } else {
                                    count += difference < 0 ? 1 : -1
                                }
                            } else {
                                count += difference < 0 ? 1 : -1
                            }
                            haptic.impactOccurred()
                            dragOffset = verticalAmount
                        }
                    }
                }
                .onEnded { value in
                    hasTriggeredHorizontalGesture = false  // Reset the trigger state
                    // If it was a very short drag (tap), handle plus/minus
                    if abs(value.translation.width) < 10 && abs(value.translation.height) < 10 {
                        let screenWidth = UIScreen.main.bounds.width
                        let isLeftSide = value.location.x < screenWidth / 2
                        
                        if isLeftSide {
                            // Only allow negative tap if we're not at 0.00
                            if !(hasDecimal && count == 0) {
                                addPlusMinusParticle(increment: false, at: value.location)
                            }
                        } else {
                            addPlusMinusParticle(increment: true, at: value.location)
                        }
                    }
                    dragOffset = 0
                }
        )
        .onAppear {
            haptic.prepare()
            errorHaptic.prepare()
        }
    }
}

struct NumberPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.5 : 1, anchor: .bottom)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    Counter()
}
