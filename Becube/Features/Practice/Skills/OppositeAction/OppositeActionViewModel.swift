//
//  OppositeActionViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// Name it, check it, act against it.
enum OppositeActionStep: Int, CaseIterable, Identifiable {
    case name, check, act

    var id: Int { rawValue }

    static let numerals = ["1", "2", "3"]
}

/// The emotions this skill has a table for, with what each one urges and what
/// acting opposite to it actually looks like.
///
/// A fixed table rather than a blank field on purpose: someone in the grip of
/// an emotion is the last person able to compose its opposite from nothing.
/// Recognising your urge in a list is a much smaller ask than inventing it.
enum Emotion: String, CaseIterable, Identifiable {
    case fear, anger, shame, sadness, guilt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fear:         return "Fear"
        case .anger:        return "Anger"
        case .shame:        return "Shame"
        case .sadness:      return "Sadness"
        case .guilt: return "Guilt"
        }
    }

    /// How the log says it.
    var feltAs: String {
        switch self {
        case .fear:         return "Felt afraid"
        case .anger:        return "Felt angry"
        case .shame:        return "Felt ashamed"
        case .sadness:      return "Felt sad"
        case .guilt: return "Felt guilty"
        }
    }

    /// What the emotion is telling you to do.
    var urge: String {
        switch self {
        case .fear:         return "Avoid it. Get away, or never start."
        case .anger:        return "Attack. Snap, blame, or go cold."
        case .shame:        return "Hide. Go quiet. Disappear."
        case .sadness:      return "Withdraw. Shut down. Do nothing."
        case .guilt: return "Apologise over and over, or avoid them entirely."
        }
    }

    /// The short form, for the one line this practice writes onto its log.
    var shortUrge: String {
        switch self {
        case .fear:         return "avoid"
        case .anger:        return "lash out"
        case .shame:        return "hide"
        case .sadness:      return "withdraw"
        case .guilt: return "over-apologise"
        }
    }

    /// What acting opposite actually looks like — fully, which is the part
    /// people skip. Half-hearted opposite action just rehearses the avoidance.
    var opposite: String {
        switch self {
        case .fear:         return "Approach what you're avoiding. Slowly, and stay with it until the fear drops."
        case .anger:        return "Step away gently. Be a little kinder than you feel like being."
        case .shame:        return "Stay in the room. Tell someone you trust, in plain words."
        case .sadness:      return "Get active. One small thing, ideally with other people in it."
        case .guilt: return "Keep doing the thing openly, and don't apologise for it."
        }
    }

    /// When the emotion is *justified* — the test for the fork on step 2.
    var whenItFits: String {
        switch self {
        case .fear:         return "there's a real threat to your safety or health right now"
        case .anger:        return "something you genuinely care about is being blocked or harmed"
        case .shame:        return "being open about this really would get you rejected by people who matter"
        case .sadness:      return "you've actually lost something that mattered"
        case .guilt: return "you've genuinely acted against your own values"
        }
    }

    var icon: String {
        switch self {
        case .fear:         return "wind"
        case .anger:        return "flame"
        case .shame:        return "eye.slash"
        case .sadness:      return "cloud.rain"
        case .guilt: return "arrow.uturn.backward"
        }
    }
}

@MainActor
@Observable
final class OppositeActionViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits

    static let planCharLimit = 120

    /// Matched to the reflection box, so the line handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let journalCharLimit = 200

    // MARK: - State

    private(set) var currentStep: OppositeActionStep = .name

    /// Steps already walked. Never emptied by revisiting one.
    private(set) var completed: Set<OppositeActionStep> = []

    private(set) var emotion: Emotion?

    /// Nil until answered. `true` sends step 3 down the fork.
    private(set) var fitsTheFacts: Bool?

    var plan: String = "" {
        // Guarded: under `@Observable` the property is rewritten into a computed
        // one, so an unconditional write here re-enters the setter forever.
        didSet {
            guard plan.count > Self.planCharLimit else { return }
            plan = String(plan.prefix(Self.planCharLimit))
        }
    }

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var canLeaveName: Bool { emotion != nil }
    var canLeaveCheck: Bool { fitsTheFacts != nil }

    /// Down the fork there is nothing left to type.
    ///
    /// Recognising that an emotion is *justified* is a completed use of this
    /// skill — arguably the more valuable one, since acting against a fitting
    /// emotion is how people talk themselves out of real signals.
    var canFinish: Bool {
        guard let fits = fitsTheFacts else { return false }
        return fits || !plan.isTrimmedEmpty
    }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns.
    var journalDraft: String? {
        guard let emotion else { return nil }

        let line: String
        if fitsTheFacts == true {
            line = "\(emotion.feltAs) — it fits the facts. A problem to solve, not an emotion to act against."
        } else {
            let done = plan.trimmed
            guard !done.isEmpty else { return nil }
            line = "\(emotion.feltAs), urge to \(emotion.shortUrge) — \(done) instead."
        }

        return Self.capped(line, to: Self.journalCharLimit)
    }

    // MARK: - PracticeSession

    // Nothing runs on its own — no clock, no animation to pace. The host still
    // calls both, so they stay and stay empty on purpose.
    func start() {}
    func stop() {}

    // MARK: - Intent

    /// Tapping a number. Only to somewhere already visited — jumping ahead
    /// would skip the step the next one is built on.
    func revisit(_ index: Int) {
        guard let step = OppositeActionStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
    }

    /// Tapping the selected emotion again clears it — a mis-tap on step 1
    /// should not be permanent.
    func select(_ emotion: Emotion) {
        self.emotion = (self.emotion == emotion) ? nil : emotion
    }

    func commitEmotion() {
        guard canLeaveName else { return }
        advance(to: .check)
    }

    func answerFitsTheFacts(_ fits: Bool) {
        fitsTheFacts = fits
        advance(to: .act)
    }

    /// The practice's natural end, down either branch.
    func finish() {
        guard canFinish else { return }
        completed.insert(.act)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: OppositeActionStep) {
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
