//
//  ChatBubble.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

struct SkillBubble: View {
    let message: String
    var bubbleWidth: CGFloat = 150
    /// Negative = tail on the left, positive = tail on the right
    var tailOffsetDenominator: CGFloat = 4

    private let brown = Color(red: 158 / 255, green: 110 / 255, blue: 74 / 255)
    private let cream = Color(red: 255 / 255, green: 253 / 255, blue: 248 / 255)

    private var bubbleShape: BulgingCardShape {
        BulgingCardShape(
            cornerRadius: 18,
            bulge: 4,
            tailPosition: tailOffsetDenominator < 0 ? .bottomLeft : .bottomRight
        )
    }

    var body: some View {
        Text(message)
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(brown)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: bubbleWidth, alignment: .center)
            .padding(.bottom, bubbleShape.tailHeight)
            .background(bubbleShape.fill(cream))
            .overlay(bubbleShape.stroke(brown, lineWidth: 2))
            .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color(.green)

        VStack(spacing: 24) {
            SkillBubble(message: "Name your Feeling")
            SkillBubble(message: "Lorem ipsum dolor sit amet Lo rem ipsum dolor sit amet Lorem ipsum dolor sit amet", tailOffsetDenominator: -4)
        }
    }
}
