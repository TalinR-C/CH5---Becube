//
//  ForestAreaViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation

@Observable
class ForestAreaViewModel {
    let forestArea: ForestArea
    let gardenStore: GardenStore

    /// The area's skills, resolved from its `copingSkillIds` and kept in that order.
    /// Unknown ids are dropped rather than crashing — content is a build invariant,
    /// but a typo in `areas.json` shouldn't take the whole screen down.
    var skills: [CopingSkill]

    var areaName: String { forestArea.name }
    
    // checks whether all skill is unlocked
    var isAllSkillUnlocked: Bool = true

    // Processing the background image name according to its area id and its unlock status
    var backgroundImage: String {
        "Backgrounds/\(forestArea.id)_\(isAllSkillUnlocked ? "colored" : "muted")"
    }
    
    // Processing the header/title file name (which is a custom vector)
    var headerImage: String {
        "Headers/\(forestArea.id)"
    }
    
    init(gardenStore: GardenStore, forestArea: ForestArea) {
        self.forestArea = forestArea
        self.skills = forestArea.copingSkillIds.compactMap { id in
            ContentRepository.skills.first(where: { $0.id == id })
        }
        self.gardenStore = gardenStore
    }
}
