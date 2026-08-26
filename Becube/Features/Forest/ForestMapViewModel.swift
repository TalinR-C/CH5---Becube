//
//  ForestMapViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

@Observable
class ForestMapViewModel {
    var columns: [GridItem]
    var forestAreas: [ForestArea]
    var skills: [CopingSkill]
    private let gardenStore: GardenStore

    var areaStatus: [(name: String, unlocked: Bool)] {
        forestAreas.map { ($0.name, gardenStore.hasUnlockedForestArea(id: $0.id)) }
    }

    init(gardenStore: GardenStore) {
        self.columns = [
            .init(.flexible(), spacing: 0, alignment: .center),
            .init(.flexible(), spacing: 0, alignment: .center)
        ]

        self.forestAreas = Bundle.main.decode([ForestArea].self, from: "areas.json")
        self.skills = Bundle.main.decode([CopingSkill].self, from: "skills_en.json")
        self.gardenStore = gardenStore
    }

    /// The areas the user may open right now — everything on a fresh garden, the
    /// remaining locked areas once the area they are in is finished, and nothing
    /// in between. Empty is what keeps the picker off the map.
    ///
    /// Computed rather than stored: the map re-reads it whenever `GardenState`
    /// changes, so collecting an area's last plant needs no separate trigger to
    /// make the next choice appear.
    var selectableAreas: [ForestArea] {
        Progression.selectableAreas(
            unlockedAreaIDs: gardenStore.gardenState.unlockedForestAreaID,
            unlockedPlantIDs: gardenStore.gardenState.unlockedPlantsID,
            in: forestAreas
        )
    }

    /// The first-run pick, which the user cannot decline — there is nowhere to
    /// go until they choose. Every later pick is a bonus and can wait.
    var isFirstAreaChoice: Bool {
        gardenStore.gardenState.unlockedForestAreaID.isEmpty
    }

    // Opens the area the user picked. Their choice is the only thing that
    // unlocks an area. The store dedups, so a double tap cannot add it twice.
    func chooseArea(_ area: ForestArea) {
        gardenStore.unlockForestArea(id: area.id)
    }

    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        gardenStore.hasUnlockedForestArea(id: area.id)
    }
}
