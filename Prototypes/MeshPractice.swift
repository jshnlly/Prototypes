//
//  MeshPractice.swift
//  Prototypes
//
//  Created by Josh Nelson on 11/28/24.
//

import SwiftUI

struct MeshPractice: View {
    @State var isPressed: Bool = false
    
    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ], colors: [
                .yellow, .yellow, .yellow,
                .blueSky1, .blueSky1, .blueSky1,
                .pinkSky1, .pinkSky1, .pinkSky1
            ])
        }.ignoresSafeArea()
    }
}

#Preview {
    MeshPractice()
}

