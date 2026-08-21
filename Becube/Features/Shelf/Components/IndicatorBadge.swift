//
//  IndicatorBadge.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 19/08/26.
//
//  Small reusable badge: the "Indicator" artwork with either a count (`Done Nx`) or a
//  rating icon layered on top of it. Both `ToolBoxPlantCard` and `PlantCard` need this
//  exact pairing twice each, so it's pulled out once instead of copy-pasted four times.
//

import SwiftUI

struct IndicatorBadge<Content: View>: View {
    private let size: CGFloat
    private let content: Content

    init(size: CGFloat = 28, @ViewBuilder content: () -> Content) {
        self.size = size
        self.content = content()
    }

    var body: some View {
        ZStack {
            Image("Indicator")
                .resizable()
                .scaledToFit()
            content
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        IndicatorBadge {
            Text("5x")
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        IndicatorBadge {
            Image(RatingAsset.assetName(forAverage: 4.2))
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        }
        IndicatorBadge {
            Image(RatingAsset.assetName(forAverage: 0))
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        }
    }
    .padding()
}
