//
//  RatingIcon.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//
//  The average-rating icon that sits inside an `IndicatorBadge` on every Shelf surface.
//  A plant with nothing rated yet draws *nothing* — the badge is simply empty — rather
//  than an outline face, which read like a real (low) score.
//

import SwiftUI

struct RatingIcon: View {
    /// The plant's average rating. `0` means nothing rated yet.
    let average: Double
    var size: CGFloat = 26

    var body: some View {
        if let assetName = RatingAsset.assetName(forAverage: average) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IndicatorBadge(size: 44) { RatingIcon(average: 4.2) }
        IndicatorBadge(size: 44) { RatingIcon(average: 1) }
        // Nothing rated yet — an empty badge.
        IndicatorBadge(size: 44) { RatingIcon(average: 0) }
    }
    .padding()
}
