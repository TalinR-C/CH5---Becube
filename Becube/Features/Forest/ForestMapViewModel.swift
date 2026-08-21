//
//  ForestMapViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

// TODO: implement

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

    // A fresh garden has nothing unlocked yet, so the user is asked to pick the
    // area they want to start in rather than being handed one.
    var needsStartingArea: Bool {
        gardenStore.gardenState.unlockedForestAreaID.isEmpty
    }

    // Opens the area the user picked on first run. Their choice is the only
    // thing that unlocks an area at this point. The store dedups, so a double
    // tap cannot add it twice.
    func chooseStartingArea(_ area: ForestArea) {
        gardenStore.unlockForestArea(id: area.id)
    }

    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        gardenStore.hasUnlockedForestArea(id: area.id)
    }
}
