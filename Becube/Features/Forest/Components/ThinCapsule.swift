//
//  ForestAreaButton.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import SwiftUI

struct ThinCapsule: View {
    var text: String
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .foregroundStyle(.white)
            )
            .foregroundStyle(.black)
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        ThinCapsule(text: "Button")
    }
}
