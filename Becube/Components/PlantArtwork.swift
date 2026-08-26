//
//  PlantArtwork.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import SwiftUI
import UIKit

extension CopingSkill {

    /// Shown for a skill whose plant hasn't been illustrated yet.
    static let placeholderImageName = "FlowerPlantPlaceholder"

    /// The plant art to draw, falling back to the placeholder when this skill's
    /// illustration isn't in the asset catalog.
    ///
    /// `Image("missing_name")` renders an empty box rather than failing, so an
    /// undrawn plant silently leaves a hole in the middle of the celebration
    /// screen — the one moment the app is trying to feel like a reward. Every
    /// skill has an `image` in the JSON; only some of them have the art. This
    /// starts using the real thing the moment it lands in the catalog, no code
    /// change needed.
    var plantImageName: String {
        UIImage(named: image) != nil ? image : Self.placeholderImageName
    }
}
