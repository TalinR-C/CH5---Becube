//
//  ToolkitService.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Pure Swift — no SwiftUI, no SwiftData
//

import Foundation

/// The rules that decide which coping skills are pinned to the Shelf's toolbox plank.
///
/// Deliberately pure, in the same spirit as `Progression`: callers hand in plain id
/// arrays and get plain id arrays back, so the rules stay testable without a
/// `ModelContext` and stay the single place the toolbox's behaviour — capacity
/// included — is defined. `GardenStore` owns the persistence side.
///
/// The toolbox is always a *subset* of the plants a user has collected: pinning only
/// changes which of them are on display, never what they own.
enum ToolkitService {

    /// How many plants fit on the plank. Four is what the artwork is drawn for — a fifth
    /// card would either run off the shelf or squash the row.
    static let capacity = 4

    /// Whether another plant can be pinned without going over `capacity`.
    static func hasRoom(in pinnedIDs: [String]) -> Bool {
        pinnedIDs.count < capacity
    }

    /// Pins `id` to the plank, at the end of the row.
    ///
    /// Returns `nil` when nothing changed — the skill is already pinned, or the plank is
    /// full — so callers can tell a real change from a no-op and skip a redundant write.
    static func pinning(_ id: String, to pinnedIDs: [String]) -> [String]? {
        guard !pinnedIDs.contains(id), hasRoom(in: pinnedIDs) else { return nil }
        return pinnedIDs + [id]
    }

    /// Unpins `id` from the plank. Returns `nil` when it wasn't pinned to begin with.
    static func unpinning(_ id: String, from pinnedIDs: [String]) -> [String]? {
        guard pinnedIDs.contains(id) else { return nil }
        return pinnedIDs.filter { $0 != id }
    }
}
