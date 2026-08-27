//
//  ActivationViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// Baseline, then options, then one thing with a time on it.
enum ActivationStep: Int, CaseIterable, Identifiable {
    case mood, list, pick, schedule

    var id: Int { rawValue }

    static let numerals = ["1", "2", "3", "4"]
}

/// One thing worth doing. A struct in an array on the ViewModel rather than its
/// own `@Observable`, matching `SolutionOption` and `EvidenceItem`.
struct Activity: Identifiable, Equatable {
    let id = UUID()
    var text: String
}

@MainActor
@Observable
final class ActivationViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits

    static let activityCharLimit = 70

    /// Enough to have a choice, few enough that step 3 stays a decision rather
    /// than a menu.
    static let maxActivities = 5

    /// Matched to the reflection box, so the line handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let journalCharLimit = 200

    /// Far enough out to be plannable, close enough to still be today.
    private static let defaultLeadTime: TimeInterval = 60 * 60

    // MARK: - State

    private(set) var currentStep: ActivationStep = .mood

    /// Steps already walked. Never emptied by revisiting one.
    private(set) var completed: Set<ActivationStep> = []

    /// Asked *first*, before any thinking about pleasant activities.
    ///
    /// Ordering matters here: brainstorming things you used to enjoy lifts mood
    /// on its own, so a baseline taken afterwards is measuring the brainstorm.
    private(set) var moodNow: Int?

    private(set) var activities: [Activity] = []

    var draftActivity: String = "" {
        // Guarded: under `@Observable` the property is rewritten into a computed
        // one, so an unconditional write here re-enters the setter forever.
        didSet {
            guard draftActivity.count > Self.activityCharLimit else { return }
            draftActivity = String(draftActivity.prefix(Self.activityCharLimit))
        }
    }

    private(set) var chosenActivityID: UUID?

    /// Deliberately unconstrained by a `DatePicker` range.
    ///
    /// A range of `now...endOfToday` is a crash waiting for 23:59, when the
    /// lower bound overtakes the upper one. The copy asks for today; the wheel
    /// doesn't need to enforce it at the cost of a trap.
    var scheduledTime: Date = Date().addingTimeInterval(ActivationViewModel.defaultLeadTime)

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var canLeaveMood: Bool { moodNow != nil }

    var canAddActivity: Bool {
        !draftActivity.isTrimmedEmpty && activities.count < Self.maxActivities
    }

    var isActivityListFull: Bool { activities.count >= Self.maxActivities }

    /// One is enough to move on.
    ///
    /// Problem-Solving requires two, because one option isn't a choice. Here the
    /// skill is *doing* something rather than choosing well, and gating a person
    /// with no motivation behind "think of another one" is how the practice
    /// loses the people it was written for.
    var canLeaveList: Bool { !activities.isEmpty }

    var canLeavePick: Bool { chosenActivityID != nil }

    var chosenActivity: Activity? {
        activities.first { $0.id == chosenActivityID }
    }

    var scheduledTimeLabel: String {
        scheduledTime.formatted(date: .omitted, time: .shortened)
    }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns. The mood reading is the baseline half of the skill — the other
    /// half is noticing it again afterwards, which is a separate use and a
    /// separate log.
    var journalDraft: String? {
        guard let activity = chosenActivity else { return nil }

        var line = "\(activity.text), \(scheduledTimeLabel)."
        if let mood = moodNow { line += " Mood before: \(mood)." }
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
        guard let step = ActivationStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
    }

    func rateMood(_ value: Int) {
        moodNow = value
    }

    func commitMood() {
        guard canLeaveMood else { return }
        advance(to: .list)
    }

    func addActivity() {
        guard canAddActivity else { return }
        activities.append(Activity(text: draftActivity.trimmed))
        draftActivity = ""
    }

    /// Removing an activity has to take any selection of it along too —
    /// otherwise step 4 keeps a choice the user can no longer see.
    func removeActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
        if chosenActivityID == activity.id { chosenActivityID = nil }
    }

    func commitList() {
        guard canLeaveList else { return }
        advance(to: .pick)
    }

    func choose(_ activity: Activity) {
        chosenActivityID = activity.id
    }

    func commitChoice() {
        guard canLeavePick else { return }
        advance(to: .schedule)
    }

    /// The practice's natural end.
    ///
    /// Nothing is scheduled with the system — `Services/ReminderScheduler` is
    /// still an empty stub, and asking for notification permission in the middle
    /// of a practice is the wrong moment for that prompt anyway. The time is
    /// recorded on the log; wiring a real reminder is a later, separate job.
    func finish() {
        completed.insert(.schedule)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: ActivationStep) {
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
