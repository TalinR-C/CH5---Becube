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

    /// The area's skills, resolved from its `copingSkillIds` and kept in that order.
    /// Unknown ids are dropped rather than crashing — content is a build invariant,
    /// but a typo in `areas.json` shouldn't take the whole screen down.
    var skills: [CopingSkill]

    var areaName: String { forestArea.name }

    init(forestArea: ForestArea) {
        self.forestArea = forestArea
        self.skills = forestArea.copingSkillIds.compactMap { id in
            ContentRepository.skills.first(where: { $0.id == id })
        }
    }
}
