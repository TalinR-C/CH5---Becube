//
//  SlefSoothingViewModel.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 26/08/26.
//

import Foundation

/// One sense's worth of the worksheet — three numbered ideas plus a
/// freeform line for anything else. Plain struct, no logic: it only
/// ever holds what the user typed.
struct SenseEntry {
    var item1: String = ""
    var item2: String = ""
    var item3: String = ""
    var otherIdeas: String = ""
}

@MainActor
@Observable
final class SelfSoothingViewModel: PracticeSession {
    let skillID: String
    var onComplete: (() -> Void)?

    var sightEntry = SenseEntry()
    var hearingEntry = SenseEntry()
    var smellEntry = SenseEntry()
    var tasteEntry = SenseEntry()
    var touchEntry = SenseEntry()

    init(skillID: String) {
        self.skillID = skillID
    }

    // Nothing to start or stop — this is entirely typing, at the user's
    // own pace. The host's Done button ends the session, same as Box
    // Breathing; onComplete is never called from in here.
    func start() {}
    func stop() {}
}
