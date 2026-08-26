//
//  PracticeService.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Record practice, grant plant — pure Swift
//

import Foundation

/// What finishing a practice earns.
///
/// A completed practice writes **the** log for that use of the skill — one log,
/// rating still empty. If the user goes on to reflect, that reflection fills in
/// this same log rather than adding a second one, which is why the id has to
/// travel back out of here.
enum PracticeService {

    /// One completed practice: the log it wrote, and whether it also granted the
    /// plant for the first time (which decides the celebration screen).
    struct Completion: Hashable {
        let skillID: String
        let logID: UUID
        let isFirstUnlock: Bool
    }

    /// `journal` is whatever the practice collected on its way through — an
    /// observation typed during STOP, say. It lands on the same log a later
    /// reflection fills in, so the two never fight over which one owns the entry.
    static func complete(skillID: String, journal: String? = nil, in store: GardenStore) -> Completion {
        let log = Log(id: UUID(), date: .now, copingID: skillID, rating: nil, journal: journal)
        store.addNewLog(log: log)
        return Completion(
            skillID: skillID,
            logID: log.id,
            isFirstUnlock: store.unlockPlant(id: skillID)
        )
    }
}
