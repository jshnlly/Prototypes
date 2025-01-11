//
//  DynamicToast.swift
//  Prototypes
//
//  Created by Josh Nelson on 1/3/25.
//

import SwiftUI

struct DynamicToast: View {
    var body: some View {
        VStack {
            
            ZStack {
                Rectangle()
                    .fill(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .frame(width: 140, height: 44)
                
                Text("Show toast")
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    DynamicToast()
}
