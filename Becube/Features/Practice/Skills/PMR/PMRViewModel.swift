//
//  PMRViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// The groups, feet upward, exactly as the skill content lists them.
///
/// Upward matters: starting at the feet means the first squeeze happens
/// somewhere nobody is self-conscious about, which is easier to actually do
/// than starting with your face.
enum MuscleGroup: Int, CaseIterable, Identifiable {
    case feet, calves, thighs, stomach, hands, arms, shoulders, face

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .feet:      return "Feet"
        case .calves:    return "Calves"
        case .thighs:    return "Thighs"
        case .stomach:   return "Stomach"
        case .hands:     return "Hands"
        case .arms:      return "Arms"
        case .shoulders: return "Shoulders"
        case .face:      return "Face"
        }
    }

    /// One concrete movement each. "Tense your calves" is an instruction nobody
    /// can follow on the first try; "point your toes up toward your knees" is.
    var instruction: String {
        switch self {
        case .feet:      return "Curl your toes down and grip."
        case .calves:    return "Point your toes up toward your knees."
        case .thighs:    return "Press your knees together and squeeze."
        case .stomach:   return "Pull your belly in tight."
        case .hands:     return "Make a fist. Squeeze hard."
        case .arms:      return "Bend your elbows and tighten your biceps."
        case .shoulders: return "Pull your shoulders up toward your ears."
        case .face:      return "Scrunch your eyes and mouth tight."
        }
    }
}

/// The two halves of every group. The release is the practice — the tensing
/// only exists to make it noticeable.
enum PMRPhase {
    case tense, release
}

/// Muscles first, then a few breaths to finish, as the content describes.
enum PMRStage {
    case muscles, breathing
}

@MainActor
@Observable
final class PMRViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Timings

    /// Matched to TIPP's paired-muscle phase, which is the same technique — a
    /// short squeeze against a release twice as long, so the letting go is what
    /// most of the time is spent on.
    static let tenseDuration: Double = 5
    static let releaseDuration: Double = 10

    static let inhaleDuration: Double = 4
    static let exhaleDuration: Double = 6
    static let breathCycles: Int = 3

    private static let restingBreathScale: CGFloat = 0.8
    private static let tickInterval: Double = 0.05

    // MARK: - State

    private(set) var stage: PMRStage = .muscles
    private(set) var currentGroup: MuscleGroup = .feet
    private(set) var phase: PMRPhase = .tense

    /// Groups actually tensed and released. A skipped group is deliberately
    /// absent — it wasn't done, and a tick that says otherwise is a lie the
    /// user can see through.
    private(set) var completed: Set<MuscleGroup> = []

    private(set) var isRunning = false
    private(set) var secondsRemaining: Double = PMRViewModel.tenseDuration
    private var phaseDuration: Double = PMRViewModel.tenseDuration

    private(set) var breathPhase: PacedBreathPhase = .inhale
    private(set) var breathCycle = 0
    private(set) var breathScale: CGFloat = PMRViewModel.restingBreathScale

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

    /// A screen you opened and walked away from is not a practice. One group
    /// released is the smallest thing that counts as having done this one.
    var isDoneEnabled: Bool { !completed.isEmpty }

    func state(of group: MuscleGroup) -> StepState {
        if group == currentGroup && stage == .muscles { return .active }
        return completed.contains(group) ? .done : .upcoming
    }

    // MARK: - PracticeSession

    /// Starts on appear. Unlike TIPP there is nothing to choose first — the
    /// order is the skill.
    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTicker()
    }

    /// Safe to call twice, which the host relies on. Leaves `completed` and the
    /// current group alone so the progress stays on screen behind the
    /// completion card.
    func stop() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    // MARK: - Intent

    /// Tapping a marker moves the practice to that group and restarts it from
    /// its tense. Forwards or back — a group you want to do again should not
    /// mean starting from the feet.
    func select(_ group: MuscleGroup) {
        stage = .muscles
        currentGroup = group
        beginTense()
        start()
    }

    /// Past this group without tensing it.
    ///
    /// The skill content carries its own caution — skip anything currently
    /// injured or in pain — so the screen has to offer a way to. A skipped
    /// group gets no tick, because it wasn't done.
    func skip() {
        guard stage == .muscles else { return }
        moveToNextGroup()
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

    private func advance() {
        switch stage {
        case .muscles:
            switch phase {
            case .tense:
                phase = .release
                setPhase(Self.releaseDuration)

            case .release:
                completed.insert(currentGroup)
                moveToNextGroup()
            }

        case .breathing:
            switch breathPhase {
            case .inhale:
                breathPhase = .exhale
                setPhase(Self.exhaleDuration)
                animateBreath()

            case .exhale:
                breathCycle += 1
                guard breathCycle < Self.breathCycles else { return finish() }
                breathPhase = .inhale
                setPhase(Self.inhaleDuration)
                animateBreath()
            }
        }
    }

    // MARK: - Flow

    private func moveToNextGroup() {
        guard let next = MuscleGroup(rawValue: currentGroup.rawValue + 1) else {
            return beginBreathing()
        }
        currentGroup = next
        beginTense()
    }

    private func beginTense() {
        phase = .tense
        setPhase(Self.tenseDuration)

        // No animation: arriving at a group should snap back to rest rather
        // than deflate from wherever the last breath left the circle.
        withTransaction(Transaction(animation: nil)) {
            breathScale = Self.restingBreathScale
        }
    }

    private func beginBreathing() {
        stage = .breathing
        breathPhase = .inhale
        breathCycle = 0
        setPhase(Self.inhaleDuration)
        animateBreath()
    }

    /// Stopping *before* `onComplete` matters: the host replaces this screen
    /// from inside that callback, and a live timer at that moment outlives it.
    private func finish() {
        stop()
        onComplete?()
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
