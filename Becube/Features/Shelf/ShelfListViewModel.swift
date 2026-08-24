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

    /// Skills pinned to the horizontal toolbox row at the top of the shelf, in the order
    /// they were pinned — mapping over the ids rather than filtering the repository, so a
    /// newly added plant lands at the end of the row instead of jumping to wherever it
    /// happens to sit in the content list.
    var toolboxSkills: [CopingSkill] {
        gardenStore.gardenState.unlockedToolboxID.compactMap { id in
            ContentRepository.skills.first { $0.id == id }
        }
    }

    /// Every coping skill the user has unlocked into their garden — the honest list,
    /// plank included. What the grid draws is `gridSkills`.
    var unlockedSkills: [CopingSkill] {
        let unlockedIDs = gardenStore.gardenState.unlockedPlantsID
        return ContentRepository.skills.filter { unlockedIDs.contains($0.id) }
    }

    /// Collected, minus whatever is standing on the plank. A pinned plant is already on
    /// screen right above the sheet, so a card for it down here would be the same plant
    /// twice — pinning still isn't a *move*, it only decides where the plant is shown.
    var gridSkills: [CopingSkill] {
        unlockedSkills.filter { !isPinned($0.id) }
    }

    /// Search never reaches past the plank: a pinned plant stays out of the grid whether
    /// or not its name matches.
    var filteredSkills: [CopingSkill] {
        guard !searchText.isEmpty else { return gridSkills }
        return gridSkills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    /// Why the grid has nothing to draw. `nil` when it has cards.
    ///
    /// Three different reasons, and naming the wrong one is worse than saying nothing —
    /// "No plants match" in front of someone who hasn't collected anything reads like a bug.
    enum EmptyState {
        case noMatches
        case allOnTheShelf
        case nothingYet
    }

    var gridEmptyState: EmptyState? {
        guard filteredSkills.isEmpty else { return nil }
        if !searchText.isEmpty { return .noMatches }
        return unlockedSkills.isEmpty ? .nothingYet : .allOnTheShelf
    }

    /// How many places on the plank are still free. The row always draws
    /// `ToolkitService.capacity` slots — a dashed `EmptyToolSlot` for each of these —
    /// so the shelf reads as four places to fill rather than a row that happens to be
    /// short.
    var emptyToolboxSlotCount: Int {
        max(0, ToolkitService.capacity - toolboxSkills.count)
    }

    /// The "press edit to add…" bubble only earns its space while the plank is completely
    /// bare. Once a plant is up there the dashed slots beside it explain themselves.
    var showsToolboxHint: Bool {
        toolboxSkills.isEmpty
    }

    // MARK: - Editing the toolbox

    /// Whether this skill is already standing on the plank — which is also what keeps
    /// it out of the grid below.
    func isPinned(_ skillID: String) -> Bool {
        gardenStore.isPinnedToToolbox(id: skillID)
    }

    /// Whether the plank has a free slot. `false` greys out every `+` badge rather than
    /// letting a tap silently do nothing.
    var toolboxHasRoom: Bool {
        gardenStore.toolboxHasRoom
    }

    /// Promotes a collected plant onto the plank. It keeps its card in the grid below —
    /// the toolbox is a subset of what's collected, not a move.
    func pin(_ skillID: String) {
        gardenStore.pinToToolbox(id: skillID)
    }

    /// Takes a plant off the plank. It stays collected either way.
    func unpin(_ skillID: String) {
        gardenStore.unpinFromToolbox(id: skillID)
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
