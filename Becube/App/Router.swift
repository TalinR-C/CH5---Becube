//
//  Router.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  NavigationPath + Route enum
//

import SwiftUI

/// Owns the app's navigation as data: which tab is showing, and the stack of
/// routes pushed inside each one.
///
/// One path per tab because that's what users expect — leaving a tab and coming
/// back should land you where you left off, not at the root.
@Observable
final class Router {

    var selectedTab: AppTab = .shelf

    var shelfPath: [Route] = []
    var gardenPath: [Route] = []
    var forestPath: [Route] = []
    /// Set while the "practised again" card is up over the practice screen.
    /// It carries the completion so the card's "Log Experience" button can point
    /// the reflection at the log that practice just wrote.
    var repeatCompletion: PracticeService.Completion?


    /// The stack belonging to `tab`, readable and writable. Everything below
    /// goes through this, so there is exactly one switch over `AppTab` in the file.
    subscript(tab: AppTab) -> [Route] {
        get {
            switch tab {
            case .shelf:  shelfPath
            case .garden: gardenPath
            case .forest: forestPath
            }
        }
        set {
            switch tab {
            case .shelf:  shelfPath = newValue
            case .garden: gardenPath = newValue
            case .forest: forestPath = newValue
            }
        }
    }

    // MARK: - Primitives

    /// Pushes onto whichever tab is on screen. This is what call sites use most
    /// of the time — a button shouldn't need to know which tab it lives in.
    func push(_ route: Route) {
        self[selectedTab].append(route)
    }

    func pop() {
        guard !self[selectedTab].isEmpty else { return }
        self[selectedTab].removeLast()
    }

    func popToRoot() {
        self[selectedTab].removeAll()
    }

    /// Replaces the stack instead of growing it. Finishing a flow is a rewind,
    /// not a push.
    func reset(to routes: [Route] = []) {
        self[selectedTab] = routes
    }

    /// Swaps the top screen for another. Used when one step of a flow *becomes*
    /// the next, rather than stacking on top of it.
    func replaceTop(with route: Route) {
        var stack = self[selectedTab]
        if !stack.isEmpty { stack.removeLast() }
        stack.append(route)
        self[selectedTab] = stack
    }

    // MARK: - Explore → Learn → Practice → Reflect

    /// The lesson's "Practice" button. Replaces the lesson so that backing out
    /// of practice returns to the plant screen, not to page 3 of the lesson the
    /// user just finished.
    func practiceAfterLearning(skillID: String) {
        replaceTop(with: .practice(skillID: skillID))
    }

    /// Practice finished — reflection replaces it, same reasoning. Carries the
    /// practice's log so reflecting fills that log in instead of writing a second one.
    func reflectAfterPractice(skillID: String, logID: UUID?) {
        replaceTop(with: .reflect(skillID: skillID, logID: logID))
    }

    /// Leaves the loop: pops every screen that belongs to it and lands on the
    /// one underneath — the forest area in Explore, the plant in the Shelf.
    ///
    /// The stack already records where the flow was entered from, so no origin
    /// has to be threaded through `learn` -> `practice` -> `reflect` to find the
    /// way back. Replacing the stack (`reset`) is what threw that away.
    func exitFlow() {
        repeatCompletion = nil
        var stack = self[selectedTab]
        while stack.last?.isFlowStep == true { stack.removeLast() }
        self[selectedTab] = stack
    }

    /// Reflection saved: the loop is over.
    func finishReflection() {
        exitFlow()
    }

    /// First time this plant has been unlocked: a full screen for it.
    func showFirstCompletion(skillID: String, logID: UUID) {
        replaceTop(with: .practiceCompletion(skillID: skillID, logID: logID))
    }

    /// Practised again: a card over the practice screen, not a new screen.
    func showRepeatCompletion(_ completion: PracticeService.Completion) {
        repeatCompletion = completion
    }
    
    // MARK: - Deep links

    /// Entry point for the toolbox widget: switch tabs and build a stack in one
    /// step. This is the thing view-embedded `NavigationLink`s cannot do —
    /// at launch none of those views exist yet.
    func openPractice(skillID: String) {
        selectedTab = .shelf
        self[.shelf] = [.skillDetail(skillID: skillID), .practice(skillID: skillID)]
    }
}
