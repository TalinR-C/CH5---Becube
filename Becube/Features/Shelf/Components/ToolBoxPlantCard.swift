//
//  ToolBoxPlantCard.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 18/08/26.
//
//  The compact card used in the horizontal "toolbox" row standing on the Shelf's top
//  plank — the user's pinned coping skills. Visually: a CommentBox speech bubble with
//  the skill's name, a flower, and its Done/Avg Rating badges sitting across the base
//  of the pot.
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

    /// Height of the plant art.
    private let flowerHeight: CGFloat = 104

    private let badgeSize: CGFloat = 32

    /// How far the badges hang below the base of the pot. The bubble-and-flower stack
    /// reserves this much empty space beneath itself and the badges are bottom-aligned
    /// into it, so they overlap the pot by `badgeSize - badgeDrop` without anything
    /// being offset outside the card's own bounds — which the horizontal ScrollView in
    /// ShelfListView would clip.
    private let badgeDrop: CGFloat = 16

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 2) {
                CommentBox(cornerRadius: 14, bulge: 2, tailPosition: .bottomCenter, contentPadding: 6) {
                    Text(name)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(ShelfPalette.darkBrown)
                        .multilineTextAlignment(.center)
                        // Three lines rather than the two the Hi-Fi shows: its four
                        // sample names are all short, but real ones ("Knowing Your
                        // Risky Situations") truncate to "Knowing Your Risky…" at two.
                        // Bubbles grow upward, so the plants below still line up.
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                        .frame(width: nameWidth)
                }

                // No plant art exists per-skill yet, so every card falls back to the
                // shared "Flower" placeholder image (per Talin's note).
                Image("Flower")
                    .resizable()
                    .scaledToFit()
                    .frame(height: flowerHeight)
            }
            .padding(.bottom, badgeDrop)

            HStack(spacing: 0) {
                IndicatorBadge(size: badgeSize) {
                    Text("\(timesCompleted)x")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(ShelfPalette.badgeText)
                }
                IndicatorBadge(size: badgeSize) {
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
