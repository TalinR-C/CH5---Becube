//
//  ShelfListViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

@Observable
class ShelfListViewModel {
    private let gardenStore: GardenStore

    var isEditing = false
    var searchText = ""

    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
    }

    /// Text on the hanging wooden sign. `GardenState.name` starts out empty (there's no
    /// onboarding flow to set it yet), so this falls back to a generic title until there is.
    var shelfTitle: String {
        let name = gardenStore.gardenState.name
        return name.isEmpty ? "My Shelf" : "\(name)'s Shelf"
    }

    /// Skills pinned to the horizontal toolbox row at the top of the shelf.
    var toolboxSkills: [CopingSkill] {
        let ids = gardenStore.gardenState.unlockedToolboxID
        return ContentRepository.skills.filter { ids.contains($0.id) }
    }

    /// Every coping skill the user has unlocked into their garden — these are the ones
    /// that get a `PlantCard` in the shelf grid below.
    var unlockedSkills: [CopingSkill] {
        let unlockedIDs = gardenStore.gardenState.unlockedPlantsID
        return ContentRepository.skills.filter { unlockedIDs.contains($0.id) }
    }

    var filteredSkills: [CopingSkill] {
        guard !searchText.isEmpty else { return unlockedSkills }
        return unlockedSkills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    /// Average self-rating + total practice count for one skill, read straight from the
    /// garden's log history. Cards call this instead of touching `gardenStore` directly.
    func stats(for skillID: String) -> (average: Double, count: Int) {
        gardenStore.getPlantAverageRating(id: skillID)
    }

    /// Builds the view model for the detail screen a shelf card navigates to. Kept here
    /// (rather than handing `gardenStore` straight to the view) so the store stays private.
    func singleSkillViewModel(for skillID: String) -> SingleSkillPlantViewModel {
        SingleSkillPlantViewModel(gardenStore: gardenStore, skillID: skillID)
    }
}
