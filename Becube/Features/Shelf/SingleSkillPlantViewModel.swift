//
//  SingleSkillPlantViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftData

@Observable
class SingleSkillPlantViewModel {
    let skillID: String
    var skill: CopingSkill?

    var isGrown: Bool = false
    var practiceCount: Int = 0
    var averageRating: Double?

    private let modelContext: ModelContext

    init(skillID: String, modelContext: ModelContext) {
        self.skillID = skillID
        self.modelContext = modelContext
    }

    func load() {
        skill = ContentRepository.skills.first(where: { $0.id == skillID })
        loadGrownStatus()
        loadStats()
    }

    private func loadGrownStatus() {
        let descriptor = FetchDescriptor<GardenState>()
        if let state = try? modelContext.fetch(descriptor).first {
            isGrown = state.unlockedPlantsID.contains(skillID)
        }
    }

    private func loadStats() {
        let targetID = skillID
        let descriptor = FetchDescriptor<Log>(
            predicate: #Predicate { $0.copingID == targetID }
        )
        guard let logs = try? modelContext.fetch(descriptor) else { return }

        practiceCount = logs.count

        let scores = logs.compactMap { $0.score }
        if !scores.isEmpty {
            averageRating = Double(scores.reduce(0, +)) / Double(scores.count)
        }
    }
}


// TODO: implement
