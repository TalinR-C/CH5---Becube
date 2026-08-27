//
//  AcceptanceViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// The four moves the skill content describes: notice what can't change, notice
/// how hard you're fighting it, say the line, then look again.
enum AcceptanceStep: Int, CaseIterable, Identifiable {
    case name, measure, accept, notice

    var id: Int { rawValue }

    static let numerals = ["1", "2", "3", "4"]
}

/// What happened between the two readings.
///
/// An enum rather than a string on the ViewModel so the copy stays in the view
/// where copy belongs — and so that "it got worse" is a case somebody had to
/// write a kind sentence for, rather than a negative number nobody handled.
enum AcceptanceOutcome {
    case eased, unchanged, harder
}

@MainActor
@Observable
final class AcceptanceViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits

    /// One thing, named plainly. A box that will not hold the whole story is
    /// the point — the story is what the fighting is made of.
    static let realityCharLimit = 120

    /// Matched to the reflection box, so the line handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let journalCharLimit = 200

    /// Long enough to be a beat rather than a tap, short enough that nobody is
    /// standing there resenting it. Roughly one slow breath out.
    static let holdDuration: Double = 4

    // MARK: - State

    private(set) var currentStep: AcceptanceStep = .name

    /// Steps already walked. Never emptied by revisiting one.
    private(set) var completed: Set<AcceptanceStep> = []

    var reality: String = "" {
        // Guarded, and it must stay guarded. On a plain stored property Swift
        // suppresses re-entry from `didSet`; under `@Observable` the property is
        // rewritten into a computed one, so an unconditional write goes back
        // through the setter and fires `didSet` again — every keystroke, forever.
        // Only write when there is genuinely something to trim.
        didSet {
            guard reality.count > Self.realityCharLimit else { return }
            reality = String(reality.prefix(Self.realityCharLimit))
        }
    }

    private(set) var fightBefore: Int?
    private(set) var fightAfter: Int?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var canLeaveName: Bool { !reality.isTrimmedEmpty }
    var canLeaveMeasure: Bool { fightBefore != nil }
    var canFinish: Bool { fightAfter != nil }

    /// "9 → 6", once both readings exist.
    var fightShift: String? {
        guard let before = fightBefore, let after = fightAfter else { return nil }
        return "\(before) → \(after)"
    }

    /// Deliberately three-way, and deliberately not "success / failure".
    ///
    /// Radical acceptance is the one skill where a number that refuses to move
    /// is a completely ordinary result — the situation hasn't changed, and the
    /// practice never promised it would. Treating `unchanged` as a miss would
    /// quietly teach the user they are bad at accepting, which is the exact
    /// opposite of the skill.
    var outcome: AcceptanceOutcome? {
        guard let before = fightBefore, let after = fightAfter else { return nil }
        if after < before { return .eased }
        if after > before { return .harder }
        return .unchanged
    }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns. Naming an unchangeable reality is the skill's own product, so
    /// unlike a thought record this one is safe to keep.
    var journalDraft: String? {
        let named = reality.trimmed
        guard !named.isEmpty else { return nil }

        let line = fightShift.map { "Not fighting: \(named)\n(fighting \($0))" }
            ?? "Not fighting: \(named)"
        return Self.capped(line, to: Self.journalCharLimit)
    }

    // MARK: - PracticeSession

    // Nothing runs on its own — the hold on step 3 is driven by the user's own
    // finger. The host still calls both, so they stay and stay empty on purpose.
    func start() {}
    func stop() {}

    // MARK: - Intent

    /// Tapping a number. Only to somewhere already visited — jumping ahead
    /// would skip the step the next one is built on.
    func revisit(_ index: Int) {
        guard let step = AcceptanceStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
    }

    func commitReality() {
        guard canLeaveName else { return }
        advance(to: .measure)
    }

    func rateBefore(_ value: Int) {
        fightBefore = value
    }

    func commitMeasure() {
        guard canLeaveMeasure else { return }
        advance(to: .accept)
    }

    /// The hold completed. Nothing to validate — holding it *is* the step.
    func affirm() {
        advance(to: .notice)
    }

    func rateAfter(_ value: Int) {
        fightAfter = value
    }

    /// The practice's natural end.
    func finish() {
        guard canFinish else { return }
        completed.insert(.notice)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: AcceptanceStep) {
        completed.insert(currentStep)
        currentStep = step
    }

    private static func capped(_ text: String, to limit: Int) -> String {
        text.count > limit ? String(text.prefix(limit)) : text
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isTrimmedEmpty: Bool { trimmed.isEmpty }
}
