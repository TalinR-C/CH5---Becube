//
//  SingleSkillPlantViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Drives the single-plant detail screen pushed from a Shelf card.
//
//  Note for Talin: this file (and SinglePlantView's init) needed a small amount of
//  wiring beyond what was asked for, purely so "tap a card -> navigate to
//  SinglePlantView" actually shows *that* plant's data instead of always the same
//  hardcoded text. It mirrors LearnViewModel's pattern: hold a skill `id`, look the
//  skill up lazily via ContentRepository, rather than pass the whole CopingSkill in.
//

import Foundation

@Observable
class SingleSkillPlantViewModel {
    private let gardenStore: GardenStore
    let skillID: String

    var skill: CopingSkill?

    init(gardenStore: GardenStore, skillID: String) {
        self.gardenStore = gardenStore
        self.skillID = skillID
    }

    /// Looks up this skill's content. Call once when the view appears.
    func loadSkill() {
        skill = ContentRepository.skills.first { $0.id == skillID }
    }

    /// Average self-rating and total times practiced, straight from the garden's log history.
    var stats: (average: Double, count: Int) {
        gardenStore.getPlantAverageRating(id: skillID)
    }

    /// The plant art for this screen: the potted drawing, standing on the plank.
    var plantImageName: String {
        skill?.plantImageName() ?? CopingSkill.placeholderImageName
    }

    /// The one-sentence summary shown on the card — `info["what"]`, not `info["how"]`.
    /// "how" is the numbered step list, which is what the Learn flow walks through and
    /// is far too long for this screen.
    var skillDescription: String {
        skill?.info["what"] ?? ""
    }
}
