//
//  GroundingViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import Foundation
import SwiftUI

/// The five senses in the order the skill counts them down, each carrying how
/// many things it asks for.
///
/// The descending count is the skill's whole shape — five is easy and gets you
/// started, one is trivial and gets you finished. `count` derives from
/// `rawValue` rather than being written out, so the two can never disagree.
enum SenseStage: Int, CaseIterable, Identifiable {
    case see, feel, hear, smell, taste

    var id: Int { rawValue }

    /// 5, 4, 3, 2, 1.
    var count: Int { SenseStage.allCases.count - rawValue }

    /// What `LetterProgress` draws across the top. It takes arbitrary strings,
    /// so the countdown works there exactly as STOP's letters do.
    static let letters = ["5", "4", "3", "2", "1"]

    var title: String {
        switch self {
        case .see:   return "5 things you can see"
        case .feel:  return "4 things you can feel"
        case .hear:  return "3 things you can hear"
        case .smell: return "2 things you can smell"
        case .taste: return "1 thing you can taste"
        }
    }

    /// Examples, always mundane. The failure mode of this skill is hunting for
    /// something worth naming — anything in the room counts, and the prompt has
    /// to say so.
    var prompt: String {
        switch self {
        case .see:   return "Look around. A lamp, a crack in the wall, your own hands."
        case .feel:  return "The floor under you, fabric on your skin, the air."
        case .hear:  return "Traffic, a fan, your own breathing."
        case .smell: return "Coffee, soap, rain. Or lean in and find one."
        case .taste: return "Whatever's already in your mouth. Or take a sip."
        }
    }

    var icon: String {
        switch self {
        case .see:   return "eye"
        case .feel:  return "hand.raised"
        case .hear:  return "ear"
        case .smell: return "wind"
        case .taste: return "fork.knife"
        }
    }
}

@MainActor
@Observable
final class GroundingViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - State

    private(set) var currentStage: SenseStage = .see

    /// How many things have been noticed in the current stage. Reset on every
    /// stage change, including a revisit.
    private(set) var noticed = 0

    /// Stages already counted through. Never emptied by going back — noticing
    /// five things twice does not undo having noticed them once.
    private(set) var completed: Set<SenseStage> = []

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws strings, not stages.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    /// A screen you opened and walked away from is not a practice. One sense
    /// counted through is the smallest thing that counts as having done this.
    var isDoneEnabled: Bool { !completed.isEmpty }

    // MARK: - PracticeSession

    // Nothing to start or stop: this practice is entirely taps, at whatever
    // pace the room allows. The host's Done button ends it early; noticing the
    // last thing ends it properly.
    func start() {}
    func stop() {}

    // MARK: - Intent

    /// One more thing noticed. Filling the current stage moves to the next, and
    /// filling the last one ends the practice.
    func notice() {
        guard noticed < currentStage.count else { return }
        noticed += 1
        guard noticed == currentStage.count else { return }
        completeStage()
    }

    /// Tapping a number goes back to that sense and starts its count again.
    /// Deliberately reachable in both directions: someone who lost count on
    /// "four things you can feel" should not have to abandon the practice.
    func select(_ stage: SenseStage) {
        currentStage = stage
        noticed = 0
    }

    // MARK: - Flow

    private func completeStage() {
        completed.insert(currentStage)

        guard let next = SenseStage(rawValue: currentStage.rawValue + 1) else {
            onComplete?()
            return
        }

        currentStage = next
        noticed = 0
    }
}
