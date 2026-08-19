//
//  ToolBoxPlantCard.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 18/08/26.
//
//  The compact card used in the horizontal "toolbox" row standing on the Shelf's top
//  plank — the user's pinned coping skills. Visually: a CommentBox speech bubble with
//  the skill's name, a flower, and its Done/Avg Rating badges underneath.
//

import SwiftUI

struct ToolBoxPlantCard: View {
    let name: String
    let averageRating: Double
    let timesCompleted: Int

    /// Fixed (not `maxWidth`) so every bubble in the row is exactly the same width,
    /// as in the Hi-Fi — and narrow enough that four cards fit across the shelf before
    /// the row needs to scroll.
    private let nameWidth: CGFloat = 60

    var body: some View {
        VStack(spacing: 4) {
            CommentBox(cornerRadius: 14, bulge: 2, tailPosition: .bottomCenter, contentPadding: 6) {
                Text(name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    // A long single word ("Grounding") can't wrap, so let it shrink a
                    // little rather than truncate to "Ground…".
                    .minimumScaleFactor(0.75)
                    .frame(width: nameWidth)
            }

            // No plant art exists per-skill yet, so every card falls back to the
            // shared "Flower" placeholder image (per Talin's note).
            Image("Flower")
                .resizable()
                .scaledToFit()
                .frame(height: 84)

            // Slight negative spacing so the two badges overlap, as they do in the Hi-Fi.
            HStack(spacing: -6) {
                IndicatorBadge(size: 32) {
                    Text("\(timesCompleted)x")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(ShelfPalette.darkBrown)
                }
                IndicatorBadge(size: 32) {
                    Image(RatingAsset.assetName(forAverage: averageRating))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 19, height: 19)
                }
            }
        }
    }
}

#Preview {
    HStack(alignment: .bottom, spacing: 8) {
        ToolBoxPlantCard(name: "Box Breathing", averageRating: 4.6, timesCompleted: 5)
        ToolBoxPlantCard(name: "5-4-3-2-1 Grounding", averageRating: 3, timesCompleted: 5)
        ToolBoxPlantCard(name: "Urge Surfing", averageRating: 2, timesCompleted: 5)
        ToolBoxPlantCard(name: "Name Your Feeling", averageRating: 0, timesCompleted: 0)
    }
    .padding(10)
    .background(ShelfPalette.background)
}
