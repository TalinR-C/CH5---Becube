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
/// One line today, but it's the seam where "skipping shouldn't grant the
/// plant", streak counting and completion haptics will land — and it keeps
/// that rule out of the view. The `Log` is still written by ReflectView,
/// because a rating is only known after reflecting.
enum PracticeService {
    @discardableResult
        static func complete(skillID: String, in store: GardenStore) -> Bool {
            let log = Log(id: UUID(), date: .now, copingID: skillID, rating: nil)
            store.addNewLog(log: log)
            return store.unlockPlant(id: skillID)
        }
}


