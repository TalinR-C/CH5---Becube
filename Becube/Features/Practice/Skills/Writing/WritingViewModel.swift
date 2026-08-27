//
//  WritingViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// Choose a length, write, then say one thing about having written.
enum WritingStage {
    case setup, writing, closing
}

@MainActor
@Observable
final class WritingViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Timings

    /// Pennebaker's protocol is 15–20 minutes. 5 and 10 are here because a
    /// twenty-minute minimum on a bad day means the practice doesn't happen at
    /// all, and a short honest write beats a long intended one.
    static let lengths = [5, 10, 15, 20]

    /// Below this, nothing has really been written yet, so the practice stays
    /// un-finishable — including through the host's Done button.
    static let minimumSeconds: Double = 120

    /// Half a second is plenty for a bar that takes twenty minutes to fill.
    /// The 0.05s tick the breathing practices use would be twenty-four thousand
    /// wake-ups for an animation nobody is watching closely.
    private static let tickInterval: Double = 0.5

    // MARK: - Limits

    /// Matched to the reflection box, so the line handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let noteCharLimit = 200

    // MARK: - State

    private(set) var stage: WritingStage = .setup
    private(set) var chosenMinutes: Int?

    private(set) var totalSeconds: Double = 0
    private(set) var secondsRemaining: Double = 0

    /// What they actually write.
    ///
    /// **Deliberately never persisted.** It lives here for the length of the
    /// screen and dies with it — nothing writes it to `Log.journal`, and the
    /// setup screen says so before a word is typed. Twenty minutes of raw
    /// writing does not belong in a 200-character reflection box, and
    /// Pennebaker's own instruction is not to reread it straight away.
    var entry: String = ""

    /// The one line that *is* kept.
    var note: String = "" {
        // Guarded: under `@Observable` the property is rewritten into a computed
        // one, so an unconditional write here re-enters the setter forever.
        didSet {
            guard note.count > Self.noteCharLimit else { return }
            note = String(note.prefix(Self.noteCharLimit))
        }
    }

    private var ticker: Timer?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// 0 at the start, 1 when the time is up. A bar that *fills* rather than
    /// drains — progress made reads better than time running out on a screen
    /// somebody is using to sit with something hard.
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return (totalSeconds - secondsRemaining) / totalSeconds
    }

    var elapsedSeconds: Double { totalSeconds - secondsRemaining }

    /// Two minutes in, stopping becomes a choice rather than an accident.
    var canFinishEarly: Bool { elapsedSeconds >= Self.minimumSeconds }

    /// The host's Done button follows the same rule as the on-screen one: not
    /// during setup, not in the first two minutes, always on the closing card.
    var isDoneEnabled: Bool {
        switch stage {
        case .setup:   return false
        case .writing: return canFinishEarly
        case .closing: return true
        }
    }

    /// Handed to the host at completion and written onto the log this practice
    /// earns — the one line, never the entry.
    var journalDraft: String? {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - PracticeSession

    /// Nothing starts on appear — the length has to be chosen first, and a
    /// clock running before that choice would be counting nothing.
    func start() {}

    /// Safe to call twice, which the host relies on.
    func stop() {
        ticker?.invalidate()
        ticker = nil
    }

    // MARK: - Intent

    func choose(minutes: Int) {
        chosenMinutes = minutes
    }

    func begin() {
        guard let minutes = chosenMinutes else { return }
        totalSeconds = Double(minutes) * 60
        secondsRemaining = totalSeconds
        stage = .writing
        startTicker()
    }

    /// Stopping before the timer runs out, once past the two-minute floor.
    func finishWriting() {
        guard stage == .writing, canFinishEarly else { return }
        endWriting()
    }

    /// The practice's natural end.
    func finish() {
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
        guard stage == .writing else { return }
        secondsRemaining = max(secondsRemaining - Self.tickInterval, 0)
        guard secondsRemaining <= 0 else { return }
        endWriting()
    }

    /// The clock stops before the stage changes, so no stray tick can land on
    /// the closing card and drag `secondsRemaining` below zero.
    private func endWriting() {
        stop()
        stage = .closing
    }
}
