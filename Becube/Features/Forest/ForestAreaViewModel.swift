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
    
    /// Whether every plant in this area has been collected.
    ///
    /// Goes through `Progression` so the check that colours the background here
    /// is the same one that offers the next area on the map — two copies of
    /// "this area is finished" would eventually disagree.
    var isAllSkillUnlocked: Bool {
        Progression.isComplete(
            forestArea,
            unlockedPlantIDs: gardenStore.gardenState.unlockedPlantsID
        )
    }

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

    /// Whether a skill's plant has already been collected into the garden.
    func isSkillUnlocked(_ skill: CopingSkill) -> Bool {
        gardenStore.hasUnlockedPlant(id: skill.id)
    }
}
