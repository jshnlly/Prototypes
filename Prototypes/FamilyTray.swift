//
//  NUXSheet.swift
//  Prototypes
//
//  Created by Josh Nelson on 12/14/24.
//

import SwiftUI

struct FamilyTray: View {
    
    @State private var buttonWidth = 200
    @State private var frameWidth: CGFloat = 0
    @State private var frameHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            
            Spacer()
            
            ZStack {
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 200, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
                
                Text("Tap to expand")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.bottom, 64)
        .edgesIgnoringSafeArea(.top)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

#Preview {
    FamilyTray()
}
