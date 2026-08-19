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
    let image: String
    let plantPhilosophy: String
    let info: [String: String]

    /// The plant's own name, shown as "Flower Name: …" on the single-plant screen.
    ///
    /// Optional because `skills_en.json` doesn't carry it yet — `decodeIfPresent` kicks
    /// in for Optionals, so the existing JSON keeps decoding untouched and the line
    /// simply doesn't render. Add `"plantName": "Hydrangea"` to a skill's entry and it
    /// appears automatically, no code change needed.
    let plantName: String?
}
