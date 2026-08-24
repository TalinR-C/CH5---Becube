//
//  Route.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 21/08/26.
//
//  Every screen the app can push, as a value.
//

import Foundation

/// One case per pushable screen. Cases carry **ids**, never model objects or
/// ViewModels — a `Route` gets hashed, compared and stored, so it has to stay a
/// cheap, stable value. The destination builder does the lookup.
///
/// `Codable` isn't needed to push, but it's what lets a widget tap or a URL
/// rebuild a whole stack later, so it costs nothing to adopt now.
enum Route: Hashable, Codable {
    case forestArea(areaID: String)
    case lockedPlant(skillID: String)
    case skillDetail(skillID: String)
    case learn(skillID: String)
    case practice(skillID: String)
    /// `logID` is the log a practice just wrote, when reflection is the tail of
    /// a practice. `nil` means the user came straight here to log an experience,
    /// so the reflection is a log of its own.
    case reflect(skillID: String, logID: UUID?)
    case reflectHistory(skillID: String)
    case practiceCompletion(skillID: String, logID: UUID)
}

extension Route {
    /// True for screens that only exist as a step of the
    /// Learn -> Practice -> Reflect loop. Leaving the loop unwinds past all of
    /// them, so the user lands back where they entered it from.
    ///
    /// `lockedPlant` counts: once the practice is done the plant isn't locked
    /// any more, so that screen is stale the moment the loop ends.
    var isFlowStep: Bool {
        switch self {
        case .lockedPlant, .learn, .practice, .practiceCompletion, .reflect:
            true
        case .forestArea, .skillDetail, .reflectHistory:
            false
        }
    }
}

/// Top-level rather than nested in `Router` so it reads cleanly next to
/// SwiftUI's own `Tab` view inside `RootView`.
enum AppTab: Hashable {
    case shelf, garden, forest
}

