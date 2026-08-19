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

        unlockFirstAreaIfNeeded()
    }

    // The first area is always available; unlock it for fresh gardens
    private func unlockFirstAreaIfNeeded() {
        guard let firstArea = forestAreas.min(by: { $0.index < $1.index }),
              !gardenStore.gardenState.unlockedForestAreaID.contains(firstArea.id) else { return }

        gardenStore.gardenState.unlockedForestAreaID.append(firstArea.id)
        gardenStore.saveData()
    }

    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        gardenStore.gardenState.unlockedForestAreaID.contains(area.id)
    }
}
