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
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ZStack {
            // Tap targets
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(uiColor: .systemBackground))
                    .onTapGesture {
                        count -= 1
                        haptic.impactOccurred()
                    }
                Rectangle()
                    .fill(Color(uiColor: .systemBackground))
                    .onTapGesture {
                        count += 1
                        haptic.impactOccurred()
                    }
            }
            
            // Number display
            Text("\(count)")
                .padding(48)
                .font(.system(size: 120))
                .fontWeight(.bold)
                .opacity(0.1)
                .contentTransition(.numericText(value: Double(count)))
                .animation(.snappy, value: count)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let verticalMovement = value.translation.height
                    let difference = verticalMovement - dragOffset
                    if abs(difference) >= 20 {
                        count += difference > 0 ? -1 : 1
                        haptic.impactOccurred()
                        dragOffset = verticalMovement
                    }
                }
                .onEnded { _ in
                    dragOffset = 0
                }
        )
        .onAppear {
            haptic.prepare()
        }
    }
}

#Preview {
    Counter()
}
