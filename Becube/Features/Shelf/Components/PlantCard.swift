//
//  PlantCard.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 19/08/26.
//
//  A collected plant in the "Plants Collected" grid on the paper sheet: an outlined
//  white card showing the plant, how many times it's been practiced, and its average
//  rating.
//

import SwiftUI

struct PlantCard: View {
    let name: String
    /// The skill's potted plant art, from `CopingSkill.plantImageName()`. Passed in
    /// rather than looked up here so the card stays a plain drawing of values.
    let imageName: String
    let averageRating: Double
    let timesCompleted: Int

    var body: some View {
        // The Paper artwork drives the card's shape: it takes the column's width and
        // derives its own height from its natural aspect, so the card is drawn at the
        // proportions it was designed at instead of being squashed into a set height.
        // Every column in the grid is the same width, so rows still line up.
        Image("Paper")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(cardContent.padding(14))
            .frame(maxWidth: .infinity)
    }

    private var cardContent: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(4)

                VStack(spacing: 6) {
                    statColumn(label: "Done") {
                        Text("\(timesCompleted)x")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(ShelfPalette.badgeText)
                    }
                    statColumn(label: "Avg\nRating") {
                        RatingIcon(average: averageRating)
                    }
                }
                .fixedSize(horizontal: false, vertical: false)
            }
            // Lets this row absorb whatever height the divider and name don't need, so
            // the flower scales up to fill the card instead of sitting small at the top.
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(ShelfPalette.paperBorder)
                .cornerRadius(20)
                .frame(height: 2)

            Text(name)
                .font(.custom("Jua-Regular", size: 16))
                .foregroundStyle(ShelfPalette.darkBrown)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }

    private func statColumn<Badge: View>(
        label: String,
        @ViewBuilder badge: () -> Badge
    ) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            IndicatorBadge(size: 34, content: badge)
        }
    }
}

#Preview {
    HStack(alignment: .top, spacing: 14) {
        PlantCard(
            name: "Box Breathing",
            imageName: "Icon/box_breathing/unlocked_vase",
            averageRating: 4.6,
            timesCompleted: 5
        )
        // An undrawn skill, so the placeholder is visible in the preview too.
        PlantCard(
            name: "Knowing Your Risky Situations",
            imageName: CopingSkill.placeholderImageName,
            averageRating: 0,
            timesCompleted: 0
        )
    }
    .padding(26)
    .background(ShelfPalette.paperFill)
}
