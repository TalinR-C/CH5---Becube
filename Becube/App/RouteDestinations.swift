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
                ForestAreaView(viewModel: ForestAreaViewModel(gardenStore: gardenStore, forestArea: area))
            }

        case .lockedPlant(let skillID):
            if let skill = ContentRepository.skill(id: skillID) {
                SingleLockedPlant(skill: skill)
            }

        case .skillDetail(let skillID):
            SinglePlantView(
                viewModel: SingleSkillPlantViewModel(gardenStore: gardenStore, skillID: skillID)
            )

        case .learn(let skillID):
            LearnView(viewModel: LearnViewModel(skillID: skillID, gardenStore: gardenStore))

        case .practice(let skillID):
            PracticeHostView(skillID: skillID)

        case .reflect(let skillID):
            if let skill = ContentRepository.skill(id: skillID) {
                ReflectView(viewModel: ReflectViewModel(gardenStore: gardenStore, current: skill))
            }

        case .reflectHistory(let skillID):
            if let skill = ContentRepository.skill(id: skillID) {
                ReflectHistoryView(viewModel: ReflectViewModel(gardenStore: gardenStore, current: skill))
            }
            
        case .practiceCompletion(let skillID):
            PracticeCompletionView(skillID: skillID)
        }
    }
}

extension View {
    /// One line on the root content of each `NavigationStack`.
    func routeDestinations() -> some View {
        modifier(RouteDestinations())
    }
}
