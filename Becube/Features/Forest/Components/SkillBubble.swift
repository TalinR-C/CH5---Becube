//
//  ChatBubble.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

import SwiftUI

struct SkillBubble: View {
    let message: String
    var bubbleWidth: CGFloat = 150 // Set your exact width here
    var tailOffsetDenominator: CGFloat = 4 // the denominator of this formula that determines the offset of tail from the center of rectangle = (Rectangle Width / Denominator)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: bubbleWidth, alignment: .center)
                    .background(Color(.systemBackground))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
            }
            .padding(.horizontal)
            
            Image(ImageResource.chatBubbleTail)
                .offset(x: bubbleWidth / tailOffsetDenominator, y: -2)
                .foregroundStyle(Color(.systemBackground))
        }
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        SkillBubble(message: "Lorem ipsum dolor sit amet Lo rem ipsum dolor sit amet Lorem ipsum dolor sit amet")
    }
}
