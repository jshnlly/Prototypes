//
//  ConfettiEffect.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/18/24.
//

import SwiftUI
import UIKit

struct ParticleEmitterView: UIViewRepresentable {
    let position: CGPoint
    let number: Int
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Create new emitter
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = position
        emitter.emitterShape = .point
        emitter.emitterSize = .zero
        emitter.birthRate = 1.0
        
        let cell = CAEmitterCell()
        
        // Basic setup
        cell.contents = createNumberImage()
        cell.scale = 0.5
        cell.scaleRange = 0.2
        
        // Emission - quick burst
        cell.birthRate = 30
        cell.lifetime = 2.0
        
        // Initial velocity - strong upward burst
        cell.velocity = 300
        cell.velocityRange = 50
        cell.emissionRange = .pi / 6
        cell.emissionLongitude = -.pi / 2
        
        // Physics
        cell.yAcceleration = 800
        
        // Appearance
        cell.alphaSpeed = -0.5
        cell.spin = 0.25
        cell.spinRange = 0.25
        
        emitter.emitterCells = [cell]
        uiView.layer.addSublayer(emitter)
        
        // Allow a brief moment of emission before stopping
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            emitter.birthRate = 0
            
            // Remove the layer after particles have faded
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                emitter.removeFromSuperlayer()
            }
        }
    }
    
    private func createNumberImage() -> CGImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = String(number)
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
        
        return image.cgImage
    }
}

struct PopEffect: View {
    let position: CGPoint
    let number: Int
    let id: UUID
    
    var body: some View {
        ParticleEmitterView(position: position, number: number)
    }
}
