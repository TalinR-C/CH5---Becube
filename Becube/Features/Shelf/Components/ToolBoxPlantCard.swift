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
    /// The skill's potted plant art, from `CopingSkill.plantImageName()`. Passed in
    /// rather than looked up here so the card stays a plain drawing of values.
    let imageName: String
    let averageRating: Double
    let timesCompleted: Int

    /// Bubble width and the space the badges hang into both come from `ToolboxSlot`, so a
    /// filled card and an `EmptyToolSlot` are the same size and sit at the same height
    /// when the row mixes the two.
    private let nameWidth = ToolboxSlot.nameWidth

    /// Height of the plant art.
    private let flowerHeight: CGFloat = 104

    private let badgeSize: CGFloat = 38

    /// How far the badges hang below the base of the pot. The bubble-and-flower stack
    /// reserves this much empty space beneath itself and the badges are bottom-aligned
    /// into it, so they overlap the pot by `badgeSize - badgeDrop` without anything
    /// being offset outside the card's own bounds — which the horizontal ScrollView in
    /// ShelfListView would clip.
    private let badgeDrop = ToolboxSlot.baseDrop

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 2) {
                CommentBox(cornerRadius: 14, bulge: 2, tailPosition: .bottomCenter, contentPadding: 6) {
                    Text(name)
                        .font(.custom("Jua-Regular", size: 12))
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

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: flowerHeight)
            }
            .padding(.bottom, badgeDrop)

            HStack(spacing: 0) {
                IndicatorBadge(size: badgeSize) {
                    Text("\(timesCompleted)x")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(ShelfPalette.badgeText)
                }
                IndicatorBadge(size: badgeSize) {
                    RatingIcon(average: averageRating, size: 24)
                }
            }
        }
        // Lifts the whole card — plant and badges together — a little above the dashed
        // slots it shares the bottom-aligned row with, so a planted pot stands prouder
        // on the plank than an empty place does.
        .padding(.bottom, ToolboxSlot.cardLift)
    }
}

#Preview {
    HStack(alignment: .bottom, spacing: 8) {
        ToolBoxPlantCard(name: "Box Breathing", imageName: "Icon/box_breathing/unlocked_vase", averageRating: 4.6, timesCompleted: 5)
        ToolBoxPlantCard(name: "Urge Surfing", imageName: "Icon/urge_surfing/unlocked_vase", averageRating: 2, timesCompleted: 5)
        ToolBoxPlantCard(name: "STOP Skill", imageName: "Icon/stop_skill/unlocked_vase", averageRating: 3, timesCompleted: 5)
        // An undrawn skill, so the placeholder is visible in the preview too.
        ToolBoxPlantCard(name: "Name Your Feeling", imageName: CopingSkill.placeholderImageName, averageRating: 0, timesCompleted: 0)
    }
    .padding(10)
    .background(ShelfPalette.background)
}
