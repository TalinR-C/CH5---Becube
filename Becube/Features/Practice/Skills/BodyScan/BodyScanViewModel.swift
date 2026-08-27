//
//  BodyScanViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

/// The regions attention travels through, in the only order it travels them.
///
/// Feet first and head last, matching the skill content — starting at the
/// furthest point from the thinking is what makes the scan a way *out* of the
/// head rather than another lap around it.
enum BodyRegion: Int, CaseIterable, Identifiable {
    case feet, legs, hips, belly, chest, arms, shoulders, head

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .feet:      return "Feet"
        case .legs:      return "Legs"
        case .hips:      return "Hips & Lower Back"
        case .belly:     return "Belly"
        case .chest:     return "Chest"
        case .arms:      return "Hands & Arms"
        case .shoulders: return "Shoulders & Neck"
        case .head:      return "Face & Head"
        }
    }

    /// Deliberately phrased as noticing, never as fixing. "Relax your
    /// shoulders" turns a scan into a task you can fail at.
    var prompt: String {
        switch self {
        case .feet:      return "Toes, soles, heels. Warmth, pressure, or nothing at all."
        case .legs:      return "Calves, knees, thighs. Notice their weight."
        case .hips:      return "Where you're being held up. Let it be heavy."
        case .belly:     return "Rising and falling on its own. Don't change it."
        case .chest:     return "The breath moving underneath. Just watch it."
        case .arms:      return "Fingers, palms, wrists, forearms."
        case .shoulders: return "Often where the day collects. Notice it, don't fix it."
        case .head:      return "Jaw, eyes, forehead, scalp."
        }
    }
}

@MainActor
@Observable
final class BodyScanViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Timings

    /// Eight regions at 25s is a little over three minutes — long enough to
    /// settle into, short enough to finish on a bad day.
    static let regionDuration: Double = 25

    private static let tickInterval: Double = 0.05

    // MARK: - State

    private(set) var currentRegion: BodyRegion = .feet

    /// Regions already scanned. Never emptied by going back to one — noticing
    /// something a second time does not undo having noticed it.
    private(set) var completed: Set<BodyRegion> = []

    private(set) var isRunning = false
    private(set) var secondsRemaining: Double = BodyScanViewModel.regionDuration

    private var ticker: Timer?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// 1 at the start of the current region, 0 at its end.
    var phaseProgress: Double { secondsRemaining / Self.regionDuration }

    var secondsLabel: Int { Int(secondsRemaining.rounded(.up)) }

    /// A screen you opened and walked away from is not a practice. One region
    /// scanned is the smallest thing that counts as having done this one.
    var isDoneEnabled: Bool { !completed.isEmpty }

    func state(of region: BodyRegion) -> StepState {
        if region == currentRegion { return .active }
        return completed.contains(region) ? .done : .upcoming
    }

    // MARK: - PracticeSession

    /// Starts the moment the screen appears. A guided scan that waits for a
    /// button is asking for one more decision than this practice is for.
    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTicker()
    }

    /// Safe to call twice, which the host relies on. Leaves `completed` and
    /// `currentRegion` alone so the progress stays on screen behind the
    /// completion card.
    func stop() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    // MARK: - Intent

    /// Tapping a marker moves the scan there and restarts that region's clock.
    /// Any region is reachable, forwards or back: a scan you have drifted out
    /// of should be rejoinable without starting over.
    func select(_ region: BodyRegion) {
        currentRegion = region
        secondsRemaining = Self.regionDuration
        start()
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
        advance()
    }

    /// This region ran out: tick it off and move up the body, or — if that was
    /// the last one — end the practice.
    ///
    /// Stopping *before* `onComplete` matters: the host replaces this screen
    /// from inside that callback, and a live timer at that moment outlives it.
    private func advance() {
        completed.insert(currentRegion)

        guard let next = BodyRegion(rawValue: currentRegion.rawValue + 1) else {
            stop()
            onComplete?()
            return
        }

        currentRegion = next
        secondsRemaining = Self.regionDuration
    }
}
