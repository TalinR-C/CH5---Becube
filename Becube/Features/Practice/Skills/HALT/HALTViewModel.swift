//
//  HALTViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// The four states the acronym is made of, in the order it spells them.
enum HALTNeed: Int, CaseIterable, Identifiable {
    case hungry, angry, lonely, tired

    var id: Int { rawValue }

    /// What `LetterProgress` draws across the top — the letters are the skill,
    /// so showing them is teaching it.
    static let letters = ["H", "A", "L", "T"]

    // `String`, not `LocalizedStringKey`: `title` gets lower-cased and joined
    // elsewhere, which `LocalizedStringKey` can't do. `String(localized:)` still
    // routes it through the same string catalog as a direct `Text` literal
    // would, so the lower-cased/joined result stays translated.
    var title: String {
        switch self {
        case .hungry: return String(localized: "Hungry")
        case .angry:  return String(localized: "Angry")
        case .lonely: return String(localized: "Lonely")
        case .tired:  return String(localized: "Tired")
        }
    }

    var question: LocalizedStringKey {
        switch self {
        case .hungry: return "Are you hungry?"
        case .angry:  return "Are you angry?"
        case .lonely: return "Are you lonely?"
        case .tired:  return "Are you tired?"
        }
    }

    /// A question behind the question. "Are you hungry?" gets a reflexive no;
    /// "when did you last eat something proper?" gets an honest answer.
    var prompt: LocalizedStringKey {
        switch self {
        case .hungry: return "When did you last eat something proper?"
        case .angry:  return "Irritated, resentful, or wound up about something?"
        case .lonely: return "Have you actually spoken to anyone today?"
        case .tired:  return "How did you sleep, and how long have you been going?"
        }
    }

    /// One concrete thing to do about it, doable in the next hour. Advice you
    /// can't act on today is just another thing to feel behind on.
    var action: LocalizedStringKey {
        switch self {
        case .hungry: return "Eat something now. Even something small changes the next hour."
        case .angry:  return "Give it ten minutes before you decide anything."
        case .lonely: return "Message one person. It doesn't have to be about how you feel."
        case .tired:  return "Rest before you decide. Twenty minutes lying down, if you can."
        }
    }

    /// The verb form, for the one line this practice writes onto its log.
    var shortAction: String {
        switch self {
        case .hungry: return "eating"
        case .angry:  return "cooling down"
        case .lonely: return "reaching out"
        case .tired:  return "resting"
        }
    }

    var icon: String {
        switch self {
        case .hungry: return "fork.knife"
        case .angry:  return "flame"
        case .lonely: return "person.2"
        case .tired:  return "moon.zzz"
        }
    }
}

/// Walking the letters, then what came of it.
enum HALTStage {
    case questions, summary
}

@MainActor
@Observable
final class HALTViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - State

    private(set) var stage: HALTStage = .questions
    private(set) var currentNeed: HALTNeed = .hungry
    private(set) var answers: [HALTNeed: Bool] = [:]

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws letters, not needs.
    var completedIndices: Set<Int> { Set(answers.keys.map(\.rawValue)) }

    /// On the summary no letter is current, so none is highlighted and all four
    /// stay tappable for a second look.
    var letterIndex: Int {
        stage == .summary ? -1 : currentNeed.rawValue
    }

    /// Everything that came back yes, in HALT order.
    var flaggedNeeds: [HALTNeed] {
        // A closure, not `filter(\.value)`: Dictionary's filter hands the
        // closure a *tuple*, and Swift has no key paths to tuple members.
        answers.filter { $0.value }.keys.sorted { $0.rawValue < $1.rawValue }
    }

    /// The one to deal with first.
    ///
    /// Acronym order, which is the rule the skill content states — the first
    /// yes wins. Swap the sort in `flaggedNeeds` if the physical two should
    /// outrank the emotional two instead.
    var primaryNeed: HALTNeed? { flaggedNeeds.first }

    /// One answer is a check-in. Walking away from an untouched screen isn't.
    var isDoneEnabled: Bool { !answers.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns. A clean check-in still says something worth keeping — knowing it
    /// is *not* one of these four is the result, not the absence of one.
    var journalDraft: String? {
        guard !answers.isEmpty else { return nil }
        guard let primary = primaryNeed else { return "Checked in — none of the four." }

        let named = flaggedNeeds.map(\.title).joined(separator: ", ")
        return "\(named) — \(primary.shortAction) first."
    }

    // MARK: - PracticeSession

    // Nothing to start or stop: four taps at whatever pace the moment allows.
    func start() {}
    func stop() {}

    // MARK: - Intent

    func answer(_ isYes: Bool) {
        answers[currentNeed] = isYes

        guard let next = HALTNeed(rawValue: currentNeed.rawValue + 1) else {
            stage = .summary
            return
        }
        currentNeed = next
    }

    /// Tapping a letter goes back to that question. The old answer stays until
    /// a new one replaces it, so a second look costs nothing.
    func select(_ need: HALTNeed) {
        stage = .questions
        currentNeed = need
    }
}
