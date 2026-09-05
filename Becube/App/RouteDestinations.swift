//
//  RouteDestinations.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 21/08/26.
//

import SwiftUI

/// Attached once per `NavigationStack`. Every pushed screen is assembled here,
/// which is what lets a call site push a route without importing the destination
/// or knowing how to build its ViewModel.
private struct RouteDestinations: ViewModifier {
    @Environment(GardenStore.self) private var gardenStore

    /// Shared with `ForestMapView`'s area buttons so a `.forestArea` push can
    /// zoom in from the tapped button instead of sliding. `nil` on every stack
    /// but the Forest tab's, which is the only route that opts into this.
    var zoomNamespace: Namespace.ID?

    func body(content: Content) -> some View {
        content.navigationDestination(for: Route.self) { route in
            destination(for: route)
                // Every pushed screen is full-screen: the tab bar belongs to the
                // three roots, not to anything stacked on top of them. Declared
                // once here so route number seventeen can't forget it.
                .toolbar(.hidden, for: .tabBar)
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .forestArea(let areaID):
            if let area = ContentRepository.area(id: areaID) {
                let areaView = ForestAreaView(
                    viewModel: ForestAreaViewModel(gardenStore: gardenStore, forestArea: area),
                    namespace: zoomNamespace
                )
                if let zoomNamespace {
                    areaView.navigationTransition(.zoom(sourceID: areaID, in: zoomNamespace))
                } else {
                    areaView
                }
            }

        case .lockedPlant(let skillID):
            if let skill = ContentRepository.skill(id: skillID) {
                let lockedView = SingleLockedPlant(skill: skill)
                if let zoomNamespace {
                    lockedView.navigationTransition(.zoom(sourceID: skillID, in: zoomNamespace))
                } else {
                    lockedView
                }
            }

        case .skillDetail(let skillID):
            SinglePlantView(
                viewModel: SingleSkillPlantViewModel(gardenStore: gardenStore, skillID: skillID)
            )

        case .learn(let skillID):
            LearnView(viewModel: LearnViewModel(skillID: skillID, gardenStore: gardenStore))

        case .practice(let skillID):
            PracticeHostView(skillID: skillID)

        case .reflect(let skillID, let logID):
            if let skill = ContentRepository.skill(id: skillID) {
                ReflectView(
                    viewModel: ReflectViewModel(gardenStore: gardenStore, current: skill, attachingTo: logID)
                )
            }

        case .reflectHistory(let skillID):
            if let skill = ContentRepository.skill(id: skillID) {
                ReflectHistoryView(viewModel: ReflectViewModel(gardenStore: gardenStore, current: skill))
            }
            
        case .practiceCompletion(let skillID, let logID):
            PracticeCompletionView(skillID: skillID, logID: logID)
        }
    }
}

extension View {
    /// One line on the root content of each `NavigationStack`. Pass
    /// `zoomNamespace` only on the stack whose root also tags a source view
    /// with a matching `.matchedTransitionSource(id:in:)` — currently just
    /// the Forest tab's map.
    func routeDestinations(zoomNamespace: Namespace.ID? = nil) -> some View {
        modifier(RouteDestinations(zoomNamespace: zoomNamespace))
    }
}
