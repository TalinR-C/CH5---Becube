//
//  Progression.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Unlock rules — pure Swift, no SwiftUI/SwiftData
//

import Foundation

/// The rules that decide what a garden has unlocked.
///
/// Deliberately pure: callers hand in plain id arrays and get plain id arrays
/// back, so the rules stay testable without a `ModelContext` and stay the single
/// place unlock behaviour is defined. `GardenStore` owns the persistence side.
enum Progression {

    /// Adds `id` to `unlockedIDs` unless it is already there.
    ///
    /// Returns `nil` when nothing changed, so callers can tell a real unlock
    /// from a no-op and skip a redundant write.
    static func unlocking(_ id: String, in unlockedIDs: [String]) -> [String]? {
        guard !unlockedIDs.contains(id) else { return nil }
        return unlockedIDs + [id]
    }

    // MARK: - Forest areas

    /// Whether every skill in `area` has been collected.
    ///
    /// Checks the area's raw `copingSkillIds` rather than skills resolved against
    /// `ContentRepository`, so a typo in `areas.json` leaves the area permanently
    /// incomplete instead of quietly counting as finished. Content is a build
    /// invariant, and a visible dead end is the easier of the two bugs to find.
    static func isComplete(_ area: ForestArea, unlockedPlantIDs: [String]) -> Bool {
        !area.copingSkillIds.isEmpty
            && area.copingSkillIds.allSatisfy { unlockedPlantIDs.contains($0) }
    }

    /// The areas the user may open right now, in map order:
    ///
    /// - nothing unlocked yet          → every area (the first-run start pick)
    /// - newest unlocked area complete → every area still locked
    /// - otherwise                     → empty
    ///
    /// The newest area is `unlockedAreaIDs.last` because `unlocking(_:in:)`
    /// appends. Progress is therefore earned one area at a time: finish where you
    /// are, then choose where to go next.
    static func selectableAreas(
        unlockedAreaIDs: [String],
        unlockedPlantIDs: [String],
        in areas: [ForestArea]
    ) -> [ForestArea] {
        let locked = areas
            .filter { !unlockedAreaIDs.contains($0.id) }
            .sorted { $0.index < $1.index }

        // First run: nothing has been chosen, so everything is on offer.
        guard let newestID = unlockedAreaIDs.last else { return locked }

        // An id with no matching area means the store outlived the content it
        // was written against. Offer nothing rather than trapping on a lookup.
        guard let newest = areas.first(where: { $0.id == newestID }),
              isComplete(newest, unlockedPlantIDs: unlockedPlantIDs)
        else { return [] }

        return locked
    }
}
