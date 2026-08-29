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

extension CopingSkill {
    /// Resolves the skill's display name from `Localizable.xcstrings` via a key derived
    /// from `id` (`skill.<id>.name`), rather than the raw JSON text in `skills_en.json` —
    /// that JSON stays English-only reference copy for content editors.
    ///
    /// Deliberately `Bundle.main.localizedString(forKey:value:table:)`, not
    /// `String(localized: String.LocalizationValue("skill.\(id).name"))`. The latter treats
    /// a `\(id)` interpolation as a *substitution argument* in the localized value, not part
    /// of the lookup key — so it looks up the literal template key (something like
    /// `"skill.%@.name"`) instead of `"skill.box_breathing.name"`, finds nothing, and falls
    /// back to printing the interpolated source string verbatim. `Bundle.localizedString`
    /// does a plain runtime string lookup with no interpolation handling, which is what a
    /// key built at runtime needs.
    var localizedName: String {
        Bundle.main.localizedString(forKey: "skill.\(id).name", value: nil, table: nil)
    }

    var localizedPlantName: String? {
        plantName == nil ? nil : Bundle.main.localizedString(forKey: "skill.\(id).plant_name", value: nil, table: nil)
    }

    var localizedPlantPhilosophy: String {
        Bundle.main.localizedString(forKey: "skill.\(id).plant_philosophy", value: nil, table: nil)
    }

    /// `key` is one of the `info` dictionary's keys (`what`, `how`, `when`, `why`).
    func localizedInfo(_ key: String) -> String {
        Bundle.main.localizedString(forKey: "skill.\(id).info.\(key)", value: nil, table: nil)
    }
}
