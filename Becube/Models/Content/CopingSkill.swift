//
//  CopingSkill.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Immutable, decoded from JSON
//

import Foundation

/// `Identifiable` (using the existing `id` field) so skill lists can drive `ForEach`
/// and `NavigationLink(value:)` directly, without every call site spelling out `id: \.id`.
struct CopingSkill: Codable, Identifiable {
    let id: String
    let index: Int
    let name: String
    /// The illustration for the Learn flow — *not* the plant. Plant art is derived
    /// from `id` instead; see `plantImageName(_:)` in `PlantArtwork.swift`.
    ///
    /// Decoded from the JSON's `"image"` key (see `CodingKeys`) rather than renaming the
    /// key itself, so the content files stay exactly as the team writes them.
    let learnImage: String
    let plantPhilosophy: String
    let info: [String: String]

    /// The plant's own name, shown as "Flower Name: …" on the single-plant screen.
    ///
    /// Optional because `skills_en.json` doesn't carry it yet — `decodeIfPresent` kicks
    /// in for Optionals, so the existing JSON keeps decoding untouched and the line
    /// simply doesn't render. Add `"plantName": "Hydrangea"` to a skill's entry and it
    /// appears automatically, no code change needed.
    let plantName: String?

    /// The JSON calls the Learn illustration `"image"`, which reads like it might be the
    /// plant. It isn't, and it hasn't been since plant art started deriving from `id`.
    /// Mapping it here keeps the Swift side honest without touching the content files —
    /// which several people edit, and where a renamed key would come back on every merge.
    private enum CodingKeys: String, CodingKey {
        case id, index, name, plantPhilosophy, info, plantName
        case learnImage = "image"
    }
}
