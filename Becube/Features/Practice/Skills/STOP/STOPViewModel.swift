//
//  STOPViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation
import SwiftUI

/// The four letters, in the only order they mean anything in.
///
/// `freeze` rather than `stop`: `PracticeSession.stop()` ends a practice, and a
/// case called `.stop` that *begins* one would sit forty lines from it meaning
/// the opposite. The letter shown to the user comes from `letters` below, so the
/// case name is free to be unambiguous instead.
enum STOPStep: Int, CaseIterable, Identifiable {
    case freeze, stepBack, observe, proceed

    var id: Int { rawValue }

    static let letters = ["S", "T", "O", "P"]
}

@MainActor
@Observable
final class STOPViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Timings

    static let freezeDuration: Double = 5
    static let inhaleDuration: Double = 4
    static let exhaleDuration: Double = 6

    /// How many things the user is asked to notice before moving on.
    static let observePromptCount = 3

    /// Matched to the reflection box, so a note written here doesn't get cut
    /// short the moment it lands on the same log.
    static let noteCharLimit = 200

    private static let restingBreathScale: CGFloat = 0.8
    private static let tickInterval: Double = 0.05

    // MARK: - State

    private(set) var currentStep: STOPStep = .freeze

    /// Steps already walked. Never emptied by revisiting one — going back to
    /// look at something again does not undo having done it.
    private(set) var completed: Set<STOPStep> = []

    private(set) var observePromptIndex = 0

    /// Optional, and deliberately not required to move on. Someone at the edge
    /// of an impulsive decision should not be blocked by a text field.
    var observationNote: String = "" {
        didSet {
            if observationNote.count > Self.noteCharLimit {
                observationNote = String(observationNote.prefix(Self.noteCharLimit))
            }
        }
    }

    private(set) var isRunning = false
    private(set) var secondsRemaining: Double = 0
    private var phaseDuration: Double = 1

    private(set) var breathPhase: PacedBreathPhase = .inhale
    private(set) var breathScale: CGFloat = STOPViewModel.restingBreathScale

    private var ticker: Timer?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// 1 at the start of the current phase, 0 at its end.
    var phaseProgress: Double {
        guard phaseDuration > 0 else { return 0 }
        return secondsRemaining / phaseDuration
    }

    var secondsLabel: Int { Int(secondsRemaining.rounded(.up)) }

    /// What `LetterProgress` needs — it draws letters, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var isLastObservePrompt: Bool {
        observePromptIndex >= Self.observePromptCount - 1
    }

    /// A screen you opened and walked away from is not a practice.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns. Whitespace-only counts as nothing written.
    var journalDraft: String? {
        let trimmed = observationNote.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - PracticeSession

    /// Unlike TIPP, STOP starts the moment the screen appears. Someone who
    /// opened this needs to stop now, not after finding a button.
    func start() {
        prepare(.freeze)
    }

    /// Safe to call twice, which the host relies on. Leaves `completed` and the
    /// note alone so both survive behind the completion card.
    func stop() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    // MARK: - Intent

    /// Tapping a letter. Only backwards, and only to somewhere already visited —
    /// skipping ahead would skip the step that hasn't happened.
    func revisit(_ index: Int) {
        guard let step = STOPStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        prepare(step)
    }

    /// Observe's "next" — through the prompts, then on to Proceed.
    func nextPrompt() {
        guard currentStep == .observe else { return }

        if isLastObservePrompt {
            advance(to: .proceed)
        } else {
            observePromptIndex += 1
        }
    }

    /// Proceed's commitment tap: the practice's natural end.
    ///
    /// The ticker is already dead — nothing is timed by this point — so no
    /// stray tick can land after the host has replaced this screen.
    func commit() {
        stop()
        completed.insert(.proceed)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: STOPStep) {
        completed.insert(currentStep)
        prepare(step)
    }

    /// Puts a step on screen and starts whatever it runs on. The timed steps
    /// begin immediately: STOP is one continuous sequence, not a menu, so
    /// stopping to press Start between letters would break the thing it teaches.
    private func prepare(_ step: STOPStep) {
        stop()
        currentStep = step

        // No animation: arriving at a step should snap to its start rather than
        // inflate from wherever the last breath left the circle.
        withTransaction(Transaction(animation: nil)) {
            breathScale = Self.restingBreathScale
        }

        switch step {
        case .freeze:
            setPhase(Self.freezeDuration)
            run()

        case .stepBack:
            breathPhase = .inhale
            setPhase(Self.inhaleDuration)
            run()
            animateBreath()

        case .observe:
            observePromptIndex = 0
            setPhase(0)

        case .proceed:
            setPhase(0)
        }
    }

    private func run() {
        isRunning = true
        ticker = Timer.scheduledTimer(withTimeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            // Fires on the main run loop, so this genuinely is main-actor work.
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    private func tick() {
        guard isRunning else { return }
        secondsRemaining = max(secondsRemaining - Self.tickInterval, 0)
        guard secondsRemaining <= 0 else { return }
        advancePhase()
    }

    private func advancePhase() {
        switch currentStep {
        case .freeze:
            advance(to: .stepBack)

        case .stepBack:
            switch breathPhase {
            case .inhale:
                breathPhase = .exhale
                setPhase(Self.exhaleDuration)
                animateBreath()

            case .exhale:
                advance(to: .observe)
            }

        case .observe, .proceed:
            // Untimed — reachable only if a ticker outlived its step.
            stop()
        }
    }

    private func setPhase(_ duration: Double) {
        phaseDuration = duration
        secondsRemaining = duration
    }

    /// One animation across the whole phase rather than one per tick — the
    /// ticker's job is the clock, not the easing.
    private func animateBreath() {
        withAnimation(.easeInOut(duration: phaseDuration)) {
            breathScale = breathPhase == .inhale ? 1.0 : Self.restingBreathScale
        }
    }
}
