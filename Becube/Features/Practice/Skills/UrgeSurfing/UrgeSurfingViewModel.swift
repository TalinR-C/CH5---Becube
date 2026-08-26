//
//  UrgeSurfingViewModel.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 26/08/26.
//

import Foundation
import SwiftUI

/// The three steps of the redesigned flow. Replaces the old six-phase
/// hold-to-continue sequence (trigger/rise/peak/fall/returnToReality).
enum UrgeSurfingStep: Int, CaseIterable {
    case name, observe, surf
}

/// Where in the body the urge shows up. Multi-select, since it can live
/// in more than one place at once.
enum BodyLocation: String, CaseIterable, Identifiable {
    case chest = "Chest"
    case stomach = "Stomach"
    case throat = "Throat"
    case hands = "Hands"
    case head = "Head"
    case wholeBody = "Whole body"
    case somewhereElse = "Somewhere else"

    var id: String { rawValue }
}

/// Drives the looping breathing wave on the last screen. No hold or tap
/// required, it just keeps cycling until the person taps "I'm okay now."
enum BreathPhaseSurfing {
    case inhale, exhale

    var label: String {
        switch self {
        case .inhale: return "Breathe in"
        case .exhale: return "Breathe out"
        }
    }
}

@MainActor
@Observable
final class UrgeSurfingViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Flow
    var step: UrgeSurfingStep = .name
    let curveSize = CGSize(width: 300, height: 160)

    // MARK: - Step 1: Name the Urge
    var urgeText: String = ""
    
    var isDoneEnabled: Bool {
        step == .surf && showReminder
    }

    var canContinueFromName: Bool {
        !urgeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Step 2: Observe Without Judgment
    var selectedLocations: Set<BodyLocation> = []

    func toggleLocation(_ location: BodyLocation) {
        if selectedLocations.contains(location) {
            selectedLocations.remove(location)
        } else {
            selectedLocations.insert(location)
        }
    }

    var canContinueFromObserve: Bool {
        !selectedLocations.isEmpty
    }

    // MARK: - Step 3: Breathe and Surf (press-free, looping)
    var breathPhase: BreathPhaseSurfing = .inhale
    var showReminder: Bool = false

    let inhaleDuration: Double = 4.0
    let exhaleDuration: Double = 6.0

    private var breathTimer: Timer?

    init(skillID: String) {
        self.skillID = skillID
    }

    /// Kept for parity with PracticeSession. The breathing loop itself
    /// only starts once the person reaches step 3, see advance() below.
    func start() {}

    func stop() {
        stopBreathingLoop()
    }

    func advance() {
        switch step {
        case .name:
            guard canContinueFromName else { return }
            withAnimation(.easeInOut(duration: 0.4)) { step = .observe }

        case .observe:
            guard canContinueFromObserve else { return }
            withAnimation(.easeInOut(duration: 0.4)) { step = .surf }
            startBreathingLoop()

        case .surf:
            stopBreathingLoop()
            onComplete?()
        }
    }

    // MARK: - Breathing loop

    private func startBreathingLoop() {
        breathPhase = .inhale
        showReminder = false
        scheduleNextBreath()
    }

    private func stopBreathingLoop() {
        breathTimer?.invalidate()
        breathTimer = nil
    }

    private func scheduleNextBreath() {
        let duration = breathPhase == .inhale ? inhaleDuration : exhaleDuration
        breathTimer?.invalidate()
        breathTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.flipBreath() }
        }
    }

    private func flipBreath() {
        // Reveal the closing reminder once, after the first full
        // inhale-exhale cycle, rather than right at the start.
        if breathPhase == .exhale, !showReminder {
            withAnimation(.easeInOut(duration: 0.6)) { showReminder = true }
        }
        breathPhase = (breathPhase == .inhale) ? .exhale : .inhale
        scheduleNextBreath()
    }
}
