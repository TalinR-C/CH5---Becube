//
//  PlantCard.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 19/08/26.
//
//  The card used inside the Shelf's grid: a torn-paper card "clipped" to the shelf
//  with a binder clip, showing a plant, how many times it's been practiced, and its
//  average rating.
//

import SwiftUI

struct PlantCard: View {
    let name: String
    let averageRating: Double
    let timesCompleted: Int
    /// Only used to pick this card's binder clip color — see `clipAssetName`.
    let plantID: String

    /// Paper.png's real pixel size (572x726), so the card keeps that shape at any width
    /// instead of the aspect ratio drifting when the grid resizes it.
    private static let paperAspectRatio: CGFloat = 572.0 / 726.0
    private static let clipAssetNames = [
        "BlueBinderclips", "GreenBinderclips", "PinkBinderclips", "YellowBinderclips"
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Image("Paper")
                .resizable()
                .aspectRatio(Self.paperAspectRatio, contentMode: .fit)
                .overlay(cardContent.padding(16))

            Image(clipAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 34)
                .offset(y: -18)
        }
        // Explicit rather than relying on the HStack's default sizing for a resizable
        // Image — this way each card in a row claims an equal share of the row's width
        // no matter what else is (or isn't) around it.
        .frame(maxWidth: .infinity)
    }

    private var cardContent: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 4) {
                // No plant art exists per-skill yet, so every card falls back to the
                // shared "Flower" placeholder image (per Talin's note).
                Image("Flower")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 8) {
                    statColumn(label: "Done") {
                        IndicatorBadge(size: 34) {
                            Text("\(timesCompleted)x")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(ShelfPalette.darkBrown)
                        }
                    }
                    statColumn(label: "Avg Rating") {
                        IndicatorBadge(size: 34) {
                            Image(RatingAsset.assetName(forAverage: averageRating))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            // Let this row absorb all the height the name and divider don't need, so
            // the flower scales up to fill the card rather than sitting small at the
            // top with dead space beneath it.
            .frame(maxHeight: .infinity)

            Rectangle()
                .fill(ShelfPalette.darkBrown.opacity(0.25))
                .frame(height: 1)

            Text(name)
                .font(.system(size: 15, weight: .bold, design: .rounded))
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
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown.opacity(0.8))
                .lineLimit(1)
            badge()
        }
    }

    /// Deterministic instead of `String.hashValue` (which is randomized every app
    /// launch for hash-flooding protection) — this way the same plant always gets
    /// the same clip color, run after run, instead of it changing on every relaunch.
    private var clipAssetName: String {
        let hash = plantID.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
        let index = abs(hash) % Self.clipAssetNames.count
        return Self.clipAssetNames[index]
    }
}

#Preview {
    HStack(alignment: .top, spacing: 20) {
        PlantCard(name: "Box Breathing", averageRating: 4.6, timesCompleted: 5, plantID: "box_breathing")
        PlantCard(name: "Delay and Distract", averageRating: 0, timesCompleted: 0, plantID: "urge_surfing")
    }
    .padding(24)
    .background(ShelfPalette.interior)
}
