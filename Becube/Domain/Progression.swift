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

    /// The area a fresh garden starts in — the lowest-index area, always
    /// available so a new user has somewhere to begin.
    static func startingArea(in areas: [ForestArea]) -> ForestArea? {
        areas.min(by: { $0.index < $1.index })
    }

    /// Adds `id` to `unlockedIDs` unless it is already there.
    ///
    /// Returns `nil` when nothing changed, so callers can tell a real unlock
    /// from a no-op and skip a redundant write.
    static func unlocking(_ id: String, in unlockedIDs: [String]) -> [String]? {
        guard !unlockedIDs.contains(id) else { return nil }
        return unlockedIDs + [id]
    }
}
