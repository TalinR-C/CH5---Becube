//
//  PracticeRegistry.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  PracticeKind → View
//

import SwiftUI

/// The practices that actually have a screen built for them.
///
/// Raw values are `CopingSkill.id`s, so a skill in `skills_en.json` and its
/// hand-built screen are linked by that id and nothing else. Only add a case
/// once its View and ViewModel exist — the switch below is exhaustive, which
/// is the entire reason for routing through an enum instead of raw strings.
enum PracticeKind: String {
    case boxBreathing = "box_breathing"
    case urgeSurfing  = "urge_surfing"
    case tippSkill    = "tipp_skill"
    case stopSkill    = "stop_skill"
    // case bodyScan   = "body_scan"
    // case fiveSenses = "five_senses"
}

/// A built practice: its ViewModel and the view that draws it, already paired.
struct PracticeScreen {
    let session: any PracticeSession
    let content: AnyView
}

/// The one place that knows which ViewModel and which View belong to which
/// skill.
enum PracticeRegistry {

    /// `nil` when the skill has no practice built yet — the host says so
    /// rather than crashing.
    static func screen(for skillID: String) -> PracticeScreen? {
        guard let kind = PracticeKind(rawValue: skillID) else { return nil }

        switch kind {
        case .boxBreathing:
            return make(BoxBreathingViewModel(skillID: skillID)) {
                BoxBreathingView(viewModel: $0)
            }

        case .urgeSurfing:
            return make(UrgeSurfingViewModel(skillID: skillID)) {
                UrgeSurfingView(viewModel: $0)
            } // <-- Added missing closing brace here

        case .tippSkill:
            return make(TIPPViewModel(skillID: skillID)) {
                TIPPView(viewModel: $0)
            }

        case .stopSkill:
            return make(STOPViewModel(skillID: skillID)) {
                STOPView(viewModel: $0)
            }
        }
    }

    /// Ties the session's concrete type to the view that takes it, so the pair
    /// is built together and the type never has to be recovered by casting.
    /// `Session` is inferred from the first argument and flows straight into
    /// the closure, which is why `$0` is fully typed inside it.
    private static func make<Session: PracticeSession, Content: View>(
        _ session: Session,
        content: (Session) -> Content
    ) -> PracticeScreen {
        PracticeScreen(session: session, content: AnyView(content(session)))
    }
}
