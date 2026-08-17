//
//  ChatBubble.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

struct ChatBubble: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white)
                Image(ImageResource.chatBubbleTail)
                    .offset(x: 20)
            }
            
            Text("Lorem ipsum dolor sit amet")
        }
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        ChatBubble()
    }
}
