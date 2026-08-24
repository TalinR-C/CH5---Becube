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
    case reflect(skillID: String)
    case reflectHistory(skillID: String)
    case practiceCompletion(skillID: String)
}

/// Top-level rather than nested in `Router` so it reads cleanly next to
/// SwiftUI's own `Tab` view inside `RootView`.
enum AppTab: Hashable {
    case shelf, garden, forest
}

