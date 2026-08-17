//
//  ForestAreaView.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import Foundation

import SwiftUI

struct ForestAreaView: View {
    var forestArea: ForestArea

    // Fixed slots for up to four skill bubbles, alternating left/right
    private let bubblePositions: [CGPoint] = [
        CGPoint(x: 100, y: 200),
        CGPoint(x: 300, y: 250),
        CGPoint(x: 100, y: 400),
        CGPoint(x: 300, y: 500)
    ]

    var body: some View {
        ZStack {
            Image(ImageResource.riverbend)
                .resizable()
                .ignoresSafeArea()
            
            Text(forestArea.name)
                .font(.largeTitle)
                .bold()
                .position(x: 200, y: 50)
                
            ForEach(Array(zip(forestArea.copingSkillIds, bubblePositions)), id: \.0) { skillId, position in
                SkillBubble(message: skillId, tailOffsetDenominator: position.x < 200 ? -4 : 4)
                    .position(position)
            }
            
            
        }
        .padding(0)
        .task {
            
        }
    }
}

//#Preview {
//    NavigationStack {
//        ForestAreaView()
//    }
//}
