//
//  PlantArtwork.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import SwiftUI
import UIKit

extension CopingSkill {

    /// Which drawing of a plant to show.
    ///
    /// Raw values are the imageset names sitting inside `Assets.xcassets/Icon/<skill id>/`.
    enum PlantArt: String {
        /// The plant as it appears in the forest, before the skill has been practiced.
        case locked
        /// The plant growing in the ground, once the skill has been collected.
        case unlocked
        /// The same plant potted, for the shelf and its cards.
        case unlockedVase = "unlocked_vase"
    }

    /// Shown for a skill whose plant hasn't been illustrated yet.
    static let placeholderImageName = "FlowerPlantPlaceholder"

    /// The plant art to draw, falling back to the placeholder when this skill's
    /// illustration isn't in the asset catalog yet.
    ///
    /// The name is derived from the skill's own `id` rather than stored alongside it,
    /// so art is wired up by dropping it into `Icon/<id>/` — no JSON to keep in sync.
    /// Both `Icon` and each skill's folder provide a namespace, which is what makes the
    /// folder path part of the asset's name; without it every skill's imagesets would
    /// be called plain `unlocked_vase` and collide.
    ///
    /// The fallback matters because `Image("missing_name")` renders an empty box rather
    /// than failing: an undrawn plant would silently leave a hole in the middle of the
    /// celebration screen — the one moment the app is trying to feel like a reward.
    func plantImageName(_ art: PlantArt = .unlockedVase) -> String {
        let name = "Icon/\(id)/\(art.rawValue)"
        return UIImage(named: name) != nil ? name : Self.placeholderImageName
    }
}
