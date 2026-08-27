//
//  IfThenViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// Write the plans, then say them.
///
/// The second step isn't ceremony: Gollwitzer's mechanism is that rehearsing
/// the sentence is what links the situation to the response, so a plan typed
/// and never re-read is only half the skill.
enum IfThenStep: Int, CaseIterable, Identifiable {
    case plan, rehearse

    var id: Int { rawValue }

    static let numerals = ["1", "2"]
}

/// One implementation intention.
///
/// The two halves are stored separately and joined for display, so the "If" and
/// "then I will" scaffolding can never be typed away — that shape is the skill,
/// not decoration around it.
struct IfThenPlan: Identifiable, Equatable {
    let id = UUID()
    var trigger: String
    var response: String

    var sentence: String { "If \(trigger), then I will \(response)." }
}

@MainActor
@Observable
final class IfThenViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits

    static let halfCharLimit = 80

    /// Three is the ceiling on purpose. The research is about one situation
    /// firing one response — a list of ten plans is a to-do list, and a to-do
    /// list needs the very motivation this skill exists to route around.
    static let maxPlans = 3

    /// Matched to the reflection box, so the plans handed onto the log don't get
    /// silently clipped the moment the user edits them there.
    static let journalCharLimit = 200

    // MARK: - State

    private(set) var currentStep: IfThenStep = .plan

    /// Steps already walked. Never emptied by revisiting one.
    private(set) var completed: Set<IfThenStep> = []

    private(set) var plans: [IfThenPlan] = []

    var draftTrigger: String = "" {
        // Guarded: under `@Observable` the property is rewritten into a computed
        // one, so an unconditional write here re-enters the setter forever.
        didSet {
            guard draftTrigger.count > Self.halfCharLimit else { return }
            draftTrigger = String(draftTrigger.prefix(Self.halfCharLimit))
        }
    }

    var draftResponse: String = "" {
        // Guarded for the same reason as `draftTrigger` above.
        didSet {
            guard draftResponse.count > Self.halfCharLimit else { return }
            draftResponse = String(draftResponse.prefix(Self.halfCharLimit))
        }
    }

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    /// The other fifteen skills, offered as ready-made "then" halves.
    ///
    /// This is the one screen where the sixteen skills stop being sixteen
    /// separate things — a plan that says "then I will do Box Breathing" is the
    /// toolbox pointing at itself. Drawn from `ContentRepository` rather than the
    /// user's own toolbox because the registry hands a practice its skill id and
    /// nothing else; narrowing it to pinned skills means giving the ViewModel a
    /// `GardenStore`, which is a bigger change than this screen is worth.
    var suggestions: [CopingSkill] {
        ContentRepository.skills.filter { $0.id != skillID }
    }

    var canAddPlan: Bool {
        !draftTrigger.isTrimmedEmpty
            && !draftResponse.isTrimmedEmpty
            && plans.count < Self.maxPlans
    }

    var isPlanListFull: Bool { plans.count >= Self.maxPlans }

    var canLeavePlan: Bool { !plans.isEmpty }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns — one sentence per line, in the order they were written.
    var journalDraft: String? {
        guard !plans.isEmpty else { return nil }
        return Self.capped(plans.map(\.sentence).joined(separator: "\n"),
                           to: Self.journalCharLimit)
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
        guard let step = IfThenStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
    }

    /// Fills the "then" half with another skill by name, leaving it editable —
    /// a suggestion, not a commitment.
    func suggest(_ skill: CopingSkill) {
        draftResponse = "do \(skill.name)"
    }

    func addPlan() {
        guard canAddPlan else { return }
        plans.append(IfThenPlan(trigger: draftTrigger.trimmed,
                                response: draftResponse.trimmed))
        draftTrigger = ""
        draftResponse = ""
    }

    func removePlan(_ plan: IfThenPlan) {
        plans.removeAll { $0.id == plan.id }
    }

    func commitPlans() {
        guard canLeavePlan else { return }
        advance(to: .rehearse)
    }

    /// The practice's natural end.
    func finish() {
        completed.insert(.rehearse)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: IfThenStep) {
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
