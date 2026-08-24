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

    var selectedTab: AppTab = .forest

    var shelfPath: [Route] = []
    var gardenPath: [Route] = []
    var forestPath: [Route] = []
    var repeatCompletionSkillID: String?


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

    /// Practice finished — reflection replaces it, same reasoning.
    func reflectAfterPractice(skillID: String) {
        replaceTop(with: .reflect(skillID: skillID))
    }

    /// Reflection saved: the loop is done. Drop the whole flow and land on the
    /// skill's plant page.
    func finishReflection(skillID: String) {
        reset(to: [.skillDetail(skillID: skillID)])
    }

    ///To indicate the unlocking plant fot the first time 
    func showFirstCompletion(skillID: String) {
        replaceTop(with: .practiceCompletion(skillID: skillID))
    }
    
    func showRepeatCompletion(skillID: String) {
        repeatCompletionSkillID = skillID
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
