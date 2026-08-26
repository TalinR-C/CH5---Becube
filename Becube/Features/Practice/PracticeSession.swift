//
//  PracticeSession.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Shared protocol every practice VM adopts
//

import Foundation

/// What `PracticeHostView` needs from a practice, whatever it draws.
///
/// Deliberately tiny: how a practice looks, and how it paces itself, stays
/// private to its own ViewModel. The host only has to run it, stop it, and
/// hear when it's over.
@MainActor
protocol PracticeSession: AnyObject, Observable {

    /// The skill being practised — the host uses it to record the completion.
    var skillID: String { get }

    /// Called when the screen appears.
    func start()

    /// Called when the screen goes away. Must be safe to call twice.
    func stop()

    /// Set by the host. A practice that ends on its own — a finite body scan,
    /// a countdown — calls this to hand control back. Open-ended ones like box
    /// breathing never do; the host's Done button drives those.
    var onComplete: (() -> Void)? { get set }

    /// Whether the host's Done button can be tapped right now.
    ///
    /// Defaults to `true`: an open-ended practice like box breathing is finished
    /// the moment the user says it is. A practice that has to actually happen
    /// before it counts — TIPP, where Done on an untouched screen would grow a
    /// plant for nothing — overrides this and makes the button be earned.
    var isDoneEnabled: Bool { get }
}

extension PracticeSession {
    var isDoneEnabled: Bool { true }
}
