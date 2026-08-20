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

        unlockFirstAreaIfNeeded()
    }

    // The first area is always available; unlock it for fresh gardens
    private func unlockFirstAreaIfNeeded() {
        guard let firstArea = Progression.startingArea(in: forestAreas) else { return }
        gardenStore.unlockForestArea(id: firstArea.id)
    }

    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        gardenStore.hasUnlockedForestArea(id: area.id)
    }
}
