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
        forestAreas.map { ($0.name, gardenStore.gardenState.unlockedForestAreaID.contains($0.id)) }
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
    // thing that unlocks an area at this point, so guard against a double tap
    // adding it twice.
    func chooseStartingArea(_ area: ForestArea) {
        guard !unlocked(area) else { return }

        gardenStore.gardenState.unlockedForestAreaID.append(area.id)
        gardenStore.saveData()
    }

    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        gardenStore.gardenState.unlockedForestAreaID.contains(area.id)
    }
}
