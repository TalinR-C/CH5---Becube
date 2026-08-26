//
//  TitleSign.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//
//  The hanging wooden sign that titles a tab: the board on its ropes with a line of
//  text sitting on the wood. Drawn by the Shelf and the Garden.
//

import SwiftUI

struct TitleSign: View {
    let title: String

    /// Height of the sign. Fixed rather than proportional so `textDrop` can be derived
    /// from it.
    var height: CGFloat = 150

    /// `Title.png` is 363x168, of which the top ~40% is rope — the board's visual centre
    /// sits at ~64% of the image height, not 50%. Nudging the text down by that
    /// difference lands it on the wood instead of floating up over the ropes.
    private var textDrop: CGFloat { height * 0.14 }

    var body: some View {
        Image("Title")
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .overlay {
                Text(title)
                    .font(.custom("Jua-Regular", size: 30))
                    .foregroundStyle(Color.darkBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 48)
                    .offset(y: textDrop)
            }
            // The board and its text are one thing to read out, not two.
            .accessibilityElement()
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Hanging it

extension View {
    /// Hangs a `TitleSign` from the very top of a full-bleed screen: up under the status
    /// bar, above everything else on the page.
    ///
    /// The sign is meant to look like it's screwed to the top edge, so it runs into the
    /// top safe area rather than starting below it. The screen using this should also
    /// hide the navigation bar — a bar reserves a strip of height above the ropes and
    /// lays its material over the artwork.
    func titleSign(_ title: String) -> some View {
        overlay(alignment: .top) {
            TitleSign(title: title)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        TitleSign(title: "My Garden")
        TitleSign(title: "Talin's Shelf")
        TitleSign(title: "A Garden With A Very Long Name")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background {
        Image("GardenBack")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
