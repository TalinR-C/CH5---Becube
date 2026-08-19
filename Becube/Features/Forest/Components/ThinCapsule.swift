//
//  ForestAreaButton.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import SwiftUI

struct ThinCapsule: View {
    var text: String

    private let brown = Color(red: 158 / 255, green: 110 / 255, blue: 74 / 255)
    private let cream = Color(red: 255 / 255, green: 253 / 255, blue: 248 / 255)

    var body: some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(brown)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(cream)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(brown, lineWidth: 2)
            )
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        ThinCapsule(text: "Button")
    }
}
