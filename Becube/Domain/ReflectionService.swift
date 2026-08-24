//
//  ReflectionService.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Pure Swift — no SwiftUI, no SwiftData
//

import Foundation

/// Saving a reflection.
///
/// A log is one *use* of a skill, so a reflection is one of two things:
/// the tail end of a practice — in which case it fills in the log that practice
/// already wrote — or an entry in its own right, when the user logs an
/// experience without practising first. `logID` is what tells them apart, and
/// this is the only place that decision is made.
enum ReflectionService {

    static func save(
        rating: Int?,
        journal: String?,
        skillID: String,
        attachingTo logID: UUID?,
        in store: GardenStore
    ) {
        let trimmed = journal?.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = (trimmed?.isEmpty == false) ? trimmed : nil

        // Falls through to a new log if the practice log has gone (a reset mid-flow):
        // better a stray log than losing what the user just wrote.
        if let logID, store.updateLog(id: logID, rating: rating, journal: text) {
            return
        }

        store.addNewLog(
            log: Log(id: UUID(), date: .now, copingID: skillID, rating: rating, journal: text)
        )
    }
}
