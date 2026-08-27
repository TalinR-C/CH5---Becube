//
//  SelfSoothingViewModel.swift
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

    /// Everything actually written for this sense, in the order it was asked
    /// for, with blanks and stray whitespace dropped. Reading them back, the
    /// four fields are one list — only the typing treats them separately.
    var filledItems: [String] {
        [item1, item2, item3, otherIdeas]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var isEmpty: Bool { filledItems.isEmpty }
}

@MainActor
@Observable
final class SelfSoothingViewModel: PracticeSession {
    let skillID: String
    var onComplete: (() -> Void)?

    /// Matched to the reflection box (`ReflectView.logCharLimit`), so the kit
    /// handed onto the log doesn't get silently clipped the moment the user
    /// edits it there.
    static let journalCharLimit = 200

    var sightEntry = SenseEntry()
    var hearingEntry = SenseEntry()
    var smellEntry = SenseEntry()
    var tasteEntry = SenseEntry()
    var touchEntry = SenseEntry()

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// The worksheet in the order it's asked, each sense paired with the label
    /// the log uses. The view keeps its own titles and icons — those are
    /// chrome, and a log line shouldn't inherit "Sense of…" from a heading.
    private var senses: [(label: String, entry: SenseEntry)] {
        [("Sight", sightEntry),
         ("Hearing", hearingEntry),
         ("Smell", smellEntry),
         ("Taste", tasteEntry),
         ("Touch", touchEntry)]
    }

    /// A screen you opened and walked away from is not a practice. One idea
    /// written down is the smallest thing that counts as having done this one.
    var isDoneEnabled: Bool {
        senses.contains { !$0.entry.isEmpty }
    }

    /// Handed to the host at completion and written onto the log this practice
    /// earns, so the kit the user just wrote is waiting in the reflection box
    /// instead of leaving with the screen.
    ///
    /// Truncated rather than composed to fit: a filled-in worksheet is usually
    /// two or three senses, and cutting the tail is better than handing Reflect
    /// something it will clip without saying so.
    var journalDraft: String? {
        let lines = senses
            .filter { !$0.entry.isEmpty }
            .map { "\($0.label): \($0.entry.filledItems.joined(separator: ", "))" }

        guard !lines.isEmpty else { return nil }

        let draft = lines.joined(separator: "\n")
        return draft.count > Self.journalCharLimit
            ? String(draft.prefix(Self.journalCharLimit))
            : draft
    }

    // MARK: - PracticeSession

    // Nothing to start or stop — this is entirely typing, at the user's
    // own pace. The host's Done button ends the session, same as Box
    // Breathing; onComplete is never called from in here.
    func start() {}
    func stop() {}
}
