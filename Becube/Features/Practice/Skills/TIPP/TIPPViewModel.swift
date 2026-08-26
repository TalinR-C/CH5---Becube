//
//  TIPPViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation
import SwiftUI

/// The four techniques, in the order the letters spell TIPP.
///
/// Order is presentation only — TIPP is a "pick one" skill, so the user opens
/// whichever of these they can actually do right now, in any order.
enum TIPPStep: Int, CaseIterable, Identifiable {
    case cold, exercise, breath, muscle

    var id: Int { rawValue }

    /// 1-based, for the badge.
    var number: Int { rawValue + 1 }
}

@MainActor
@Observable
final class TIPPViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Timings
    //
    // Deliberately short. TIPP is for the minutes when someone is close to
    // doing something they will regret, so every phase has to be survivable at
    // that moment — a two-minute exercise block would simply be abandoned.

    static let exerciseDuration: Double = 10
    static let inhaleDuration: Double = 4
    /// Longer out than in. That ratio is the whole mechanism: a long exhale is
    /// what actually engages the parasympathetic brake.
    static let exhaleDuration: Double = 6
    static let breathCycles: Int = 3
    static let tenseDuration: Double = 5
    static let releaseDuration: Double = 10

    /// The circle's size on a full exhale — where the breath starts and returns
    /// to. Not far off 1: the point is a visible rise and fall, and a circle
    /// that collapses to a dot is harder to follow than one that just breathes.
    private static let restingBreathScale: CGFloat = 0.8

    private static let tickInterval: Double = 0.05

    // MARK: - State

    /// The expanded row, or `nil` for the plain list. There is no "current
    /// step" until the user chooses one — that is what makes this pick-one
    /// rather than a march through four.
    private(set) var openStep: TIPPStep?

    private(set) var completed: Set<TIPPStep> = []
    private(set) var isRunning = false

    /// Shown after a technique finishes. DBT's actual instruction is to stack
    /// another technique if you are still activated, so we ask instead of
    /// assuming either that one was enough or that four are required.
    private(set) var isAskingIfSettled = false

    /// Counts down within the current phase. Drives both the ring and its number.
    private(set) var secondsRemaining: Double = 0
    private var phaseDuration: Double = 1

    private(set) var breathPhase: PacedBreathPhase = .inhale
    private(set) var breathCycle = 0
    private(set) var breathScale: CGFloat = TIPPViewModel.restingBreathScale
    private(set) var isTensing = true

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

    /// Whole seconds for the label. Rounded up so the first second reads "10"
    /// rather than "9", and the last one never shows 0 while the ring is still
    /// closing.
    var secondsLabel: Int { Int(secondsRemaining.rounded(.up)) }

    /// Whether "add another" is still on the table.
    var hasUntriedSteps: Bool { completed.count < TIPPStep.allCases.count }

    /// The host's Done button. A screen you opened and did nothing on is not a
    /// practice, and should not grow a plant.
    var isDoneEnabled: Bool { !completed.isEmpty }

    func state(of step: TIPPStep) -> StepState {
        if openStep == step { return .active }
        return completed.contains(step) ? .done : .upcoming
    }

    // MARK: - PracticeSession

    /// Nothing runs on its own: the user picks a technique first. The host
    /// still calls this, so it stays here and stays empty on purpose.
    func start() {}

    /// Safe to call twice, which the host relies on — it stops the session on
    /// completion and again in `onDisappear`. Deliberately leaves `completed`
    /// alone so the ticks stay on screen behind the completion card.
    func stop() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    // MARK: - Intent

    /// Tapping a row opens it, or closes it if it was already open. A finished
    /// step can be reopened and run again — its tick stays either way.
    func select(_ step: TIPPStep) {
        stop()
        isAskingIfSettled = false
        openStep = (openStep == step) ? nil : step
        resetPhase(for: openStep)
    }

    /// Cold has no clock. You are holding an ice cube; the phone cannot tell,
    /// so it asks.
    func markColdDone() {
        finish(.cold)
    }

    /// Starts the timed part of whichever step is open.
    func begin() {
        guard let step = openStep, step != .cold, !isRunning else { return }
        resetPhase(for: step)
        isRunning = true
        startTicker()
        if step == .breath { animateBreath() }
    }

    /// "Not yet" — back to the list to add another technique.
    func continueWithAnother() {
        isAskingIfSettled = false
    }

    /// "I'm steadier" — the practice's natural end.
    ///
    /// `finish` already killed the ticker before this can be reached, so no
    /// stray tick can land after the host has replaced this screen.
    func settle() {
        isAskingIfSettled = false
        stop()
        onComplete?()
    }

    // MARK: - Clock

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            // Fires on the main run loop, so this genuinely is main-actor work —
            // `assumeIsolated` is how you tell the compiler that once the class
            // is `@MainActor`.
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    private func tick() {
        guard isRunning else { return }
        secondsRemaining = max(secondsRemaining - Self.tickInterval, 0)
        guard secondsRemaining <= 0 else { return }
        advancePhase()
    }

    /// The current phase ran out: either move to the next phase of this
    /// technique, or tick the technique off.
    private func advancePhase() {
        guard let step = openStep else { return stop() }

        switch step {
        case .cold:
            finish(.cold)

        case .exercise:
            finish(.exercise)

        case .breath:
            switch breathPhase {
            case .inhale:
                breathPhase = .exhale
                setPhase(Self.exhaleDuration)
                animateBreath()

            case .exhale:
                breathCycle += 1
                guard breathCycle < Self.breathCycles else { return finish(.breath) }
                breathPhase = .inhale
                setPhase(Self.inhaleDuration)
                animateBreath()
            }

        case .muscle:
            if isTensing {
                isTensing = false
                setPhase(Self.releaseDuration)
            } else {
                finish(.muscle)
            }
        }
    }

    /// A technique is done: tick it, stop the clock, and ask whether that was
    /// enough.
    ///
    /// Stopping *before* the prompt matters — the answer may be `settle()`,
    /// which hands control back to the host, and a live timer at that moment
    /// outlives the screen.
    private func finish(_ step: TIPPStep) {
        stop()
        completed.insert(step)
        openStep = nil
        isAskingIfSettled = true
    }

    // MARK: - Phase setup

    private func resetPhase(for step: TIPPStep?) {
        breathCycle = 0
        breathPhase = .inhale
        isTensing = true

        // No animation: reopening a step should snap back to its start rather
        // than inflate from wherever the last breath left the circle.
        withTransaction(Transaction(animation: nil)) {
            breathScale = Self.restingBreathScale
        }

        switch step {
        case .exercise:     setPhase(Self.exerciseDuration)
        case .breath:       setPhase(Self.inhaleDuration)
        case .muscle:       setPhase(Self.tenseDuration)
        case .cold, .none:  setPhase(0)
        }
    }

    private func setPhase(_ duration: Double) {
        phaseDuration = duration
        secondsRemaining = duration
    }

    /// Drives the circle across the whole phase in one animation rather than
    /// per tick — the ticker's job is the clock, not the easing.
    private func animateBreath() {
        withAnimation(.easeInOut(duration: phaseDuration)) {
            breathScale = breathPhase == .inhale ? 1.0 : Self.restingBreathScale
        }
    }
}
