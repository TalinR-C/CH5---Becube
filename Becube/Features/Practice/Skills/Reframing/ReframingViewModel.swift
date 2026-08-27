//
//  ReframingViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// A thought record, in the order Beck's model works it: catch the thought,
/// weigh it both ways, then write what's actually supported.
///
/// Numbered rather than lettered — like Problem-Solving, this skill has no
/// acronym to spell.
enum ReframingStep: Int, CaseIterable, Identifiable {
    case thought, evidenceFor, evidenceAgainst, balanced

    var id: Int { rawValue }

    static let numerals = ["1", "2", "3", "4"]
}

/// One line of evidence. A struct in an array on the ViewModel rather than its
/// own `@Observable`, matching `SolutionOption` — it holds text and nothing else.
struct EvidenceItem: Identifiable, Equatable {
    let id = UUID()
    var text: String
}

@MainActor
@Observable
final class ReframingViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits

    /// "Exactly as it came" is the instruction. A box that will not hold a
    /// paragraph teaches that better than a label asking nicely.
    static let thoughtCharLimit = 120
    static let evidenceCharLimit = 70

    /// Roomier than the thought it replaces: a balanced version has to carry a
    /// qualification, and "I made a mistake this time, not every time" is
    /// longer than "I always mess everything up".
    static let balancedCharLimit = 140

    static let maxEvidence = 4

    /// Matched to the reflection box, so the line handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let journalCharLimit = 200

    /// 0–10, the scale every thought record uses.
    static let beliefRange = 0...10

    // MARK: - State

    private(set) var currentStep: ReframingStep = .thought

    /// Steps already walked. Never emptied by revisiting one.
    private(set) var completed: Set<ReframingStep> = []

    var thought: String = "" {
        // Guarded, and it must stay guarded. On a plain stored property Swift
        // suppresses re-entry from `didSet`; under `@Observable` the property is
        // rewritten into a computed one, so an unconditional write goes back
        // through the setter and fires `didSet` again — every keystroke, forever.
        // Only write when there is genuinely something to trim.
        didSet {
            guard thought.count > Self.thoughtCharLimit else { return }
            thought = String(thought.prefix(Self.thoughtCharLimit))
        }
    }

    /// Optional until answered, deliberately: pre-setting it to 5 would collect
    /// a number nobody chose, and the whole payoff of this practice is the
    /// difference between two numbers the user meant.
    private(set) var beliefBefore: Int?

    private(set) var evidenceFor: [EvidenceItem] = []
    private(set) var evidenceAgainst: [EvidenceItem] = []

    var draftFor: String = "" {
        // Guarded, and it must stay guarded. On a plain stored property Swift
        // suppresses re-entry from `didSet`; under `@Observable` the property is
        // rewritten into a computed one, so an unconditional write goes back
        // through the setter and fires `didSet` again — every keystroke, forever.
        // Only write when there is genuinely something to trim.
        didSet {
            guard draftFor.count > Self.evidenceCharLimit else { return }
            draftFor = String(draftFor.prefix(Self.evidenceCharLimit))
        }
    }

    var draftAgainst: String = "" {
        // Guarded, and it must stay guarded. On a plain stored property Swift
        // suppresses re-entry from `didSet`; under `@Observable` the property is
        // rewritten into a computed one, so an unconditional write goes back
        // through the setter and fires `didSet` again — every keystroke, forever.
        // Only write when there is genuinely something to trim.
        didSet {
            guard draftAgainst.count > Self.evidenceCharLimit else { return }
            draftAgainst = String(draftAgainst.prefix(Self.evidenceCharLimit))
        }
    }

    var balanced: String = "" {
        // Guarded, and it must stay guarded. On a plain stored property Swift
        // suppresses re-entry from `didSet`; under `@Observable` the property is
        // rewritten into a computed one, so an unconditional write goes back
        // through the setter and fires `didSet` again — every keystroke, forever.
        // Only write when there is genuinely something to trim.
        didSet {
            guard balanced.count > Self.balancedCharLimit else { return }
            balanced = String(balanced.prefix(Self.balancedCharLimit))
        }
    }

    private(set) var beliefAfter: Int?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var canLeaveThought: Bool { !thought.isTrimmedEmpty && beliefBefore != nil }

    var canAddFor: Bool { !draftFor.isTrimmedEmpty && evidenceFor.count < Self.maxEvidence }
    var canAddAgainst: Bool { !draftAgainst.isTrimmedEmpty && evidenceAgainst.count < Self.maxEvidence }

    /// Both evidence steps can be left empty on purpose.
    ///
    /// Someone using this at 3am who cannot think of a single counter-argument
    /// is exactly the person who must not be trapped on step 3. Coming up empty
    /// is itself a finding, and the balanced rewrite is still reachable.
    var canFinish: Bool { !balanced.isTrimmedEmpty && beliefAfter != nil }

    /// "8 → 4", once both numbers exist. Nil before that, and nil is what stops
    /// the view claiming a shift that hasn't been measured.
    var beliefShift: String? {
        guard let before = beliefBefore, let after = beliefAfter else { return nil }
        return "\(before) → \(after)"
    }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns.
    ///
    /// **Only ever the balanced thought.** Falling back to the original when
    /// there is no rewrite would file "I always mess everything up" into the
    /// user's own history, which is the opposite of what this skill is for.
    var journalDraft: String? {
        let rewrite = balanced.trimmed
        guard !rewrite.isEmpty else { return nil }

        let line = beliefShift.map { "\(rewrite)\n(belief \($0))" } ?? rewrite
        return Self.capped(line, to: Self.journalCharLimit)
    }

    // MARK: - PracticeSession

    // Nothing runs on its own here — no clock, no animation to pace. The host
    // still calls both, so they stay and stay empty on purpose.
    func start() {}
    func stop() {}

    // MARK: - Intent

    /// Tapping a number. Only to somewhere already visited — jumping ahead
    /// would skip the step the next one is built on.
    func revisit(_ index: Int) {
        guard let step = ReframingStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
    }

    func rateBefore(_ value: Int) {
        beliefBefore = value
    }

    func rateAfter(_ value: Int) {
        beliefAfter = value
    }

    func commitThought() {
        guard canLeaveThought else { return }
        advance(to: .evidenceFor)
    }

    func addFor() {
        guard canAddFor else { return }
        evidenceFor.append(EvidenceItem(text: draftFor.trimmed))
        draftFor = ""
    }

    func removeFor(_ item: EvidenceItem) {
        evidenceFor.removeAll { $0.id == item.id }
    }

    func commitFor() {
        advance(to: .evidenceAgainst)
    }

    func addAgainst() {
        guard canAddAgainst else { return }
        evidenceAgainst.append(EvidenceItem(text: draftAgainst.trimmed))
        draftAgainst = ""
    }

    func removeAgainst(_ item: EvidenceItem) {
        evidenceAgainst.removeAll { $0.id == item.id }
    }

    func commitAgainst() {
        advance(to: .balanced)
    }

    /// The practice's natural end.
    func finish() {
        guard canFinish else { return }
        completed.insert(.balanced)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: ReframingStep) {
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
