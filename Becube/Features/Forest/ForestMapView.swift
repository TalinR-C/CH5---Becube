//
//  ForestMapView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI
import SwiftData

struct ForestMapView: View {

    @Environment(GardenStore.self) private var gardenStore
    @Environment(Router.self) private var router
    @State private var viewModel: ForestMapViewModel?
    @State private var showAreaLocked = false
    /// Reset in `onAppear`, so a picker waved away comes back on the next visit
    /// to the tab — and the moment the user pops back from the area they just
    /// finished. Nothing to persist: declining a free area is not a decision
    /// worth remembering past the visit it was made in.
    @State private var pickerDismissed = false

    // Fixed slots on the map, one per area in areas.json order — the ForEach
    // below zips the two by index, so an entry's place in THIS array is what
    // decides where its area sits, not the order the points read in.
    //
    // Pond and Field are deliberately out of reading order: Field takes the
    // top-right slot and Pond the bottom-right one.
    private let areaPositions: [CGPoint] = [
        CGPoint(x: 100, y: 130),  // Waterfall — top left
        CGPoint(x: 300, y: 600),  // Pond      — bottom right
        CGPoint(x: 100, y: 500),  // Forest    — bottom left
        CGPoint(x: 290, y: 180)   // Field     — top right
    ]

    // The NavigationStack lives in RootView now, one per tab, so this view is
    // just the map. Wrapping it in a second stack here would swallow every
    // push and leave the router's path empty.
    var body: some View {
        ZStack {
            Image(ImageResource.Backgrounds.map)
                .resizable()
                .ignoresSafeArea()

            if let viewModel {
                ForEach(Array(zip(viewModel.forestAreas, areaPositions)), id: \.0.id) { area, position in
                    areaNode(area, viewModel: viewModel)
                        .position(position)
                }

                // Not a push but a tab change: the Garden is a peer of the
                // Forest, not a screen inside it. Only the router can say that,
                // which is why this button had nowhere to point before.
                Button {
                    router.selectedTab = .garden
                } label: {
                    GoToGardenButton()
                }
                .buttonStyle(.plain)
                .position(x: 200, y: 400)

                modals(for: viewModel)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ForestMapViewModel(gardenStore: gardenStore)
            }
        }
        .onAppear { pickerDismissed = false }
    }

    /// An unlocked area navigates into itself; a locked one explains why it
    /// cannot be entered instead of sitting there inert.
    ///
    /// Both outcomes are now a plain `Button` — pushing a route and raising a
    /// modal are the same kind of action, so they no longer need two different
    /// controls to express them.
    private func areaNode(_ area: ForestArea, viewModel: ForestMapViewModel) -> some View {
        let status = (name: area.name, unlocked: viewModel.unlocked(area))

        return Button {
            if status.unlocked {
                router.push(.forestArea(areaID: area.id))
            } else {
                showAreaLocked = true
            }
        } label: {
            AreaButton(areaStatus: status)
        }
        .buttonStyle(.plain)
    }

    /// Whether the map is currently offering a choice of area.
    ///
    /// `selectableAreas` is the rule; `pickerDismissed` only ever hides a pick
    /// the user could have taken, never one they have not earned. The first-run
    /// pick ignores it — there is nowhere to go until it is made.
    private func showsPicker(_ viewModel: ForestMapViewModel) -> Bool {
        guard !viewModel.selectableAreas.isEmpty else { return false }
        return viewModel.isFirstAreaChoice || !pickerDismissed
    }

    /// Waving the picker away, or `nil` on the first-run pick where declining
    /// is not on offer. Spelled out as a method so the optional closure has a
    /// declared type rather than one inferred from a `nil`-armed ternary.
    private func dismissAction(for viewModel: ForestMapViewModel) -> (() -> Void)? {
        guard !viewModel.isFirstAreaChoice else { return nil }
        return {
            withAnimation(.easeOut(duration: 0.2)) {
                pickerDismissed = true
            }
        }
    }

    /// The picker takes priority: on first run every area is locked, so the
    /// locked modal would otherwise be all the user could reach.
    @ViewBuilder
    private func modals(for viewModel: ForestMapViewModel) -> some View {
        if showsPicker(viewModel) {
            AreaPickerModal(
                areas: viewModel.selectableAreas,
                title: viewModel.isFirstAreaChoice
                    ? "Where to first?"
                    : "New area unlocked",
                message: viewModel.isFirstAreaChoice
                    ? "Select an area you want to explore first."
                    : "You've collected every plant here. Pick where to explore next.",
                onDismiss: dismissAction(for: viewModel)
            ) { area in
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.chooseArea(area)
                }
            }
        } else if showAreaLocked {
            AreaLockedModal {
                withAnimation(.easeOut(duration: 0.2)) {
                    showAreaLocked = false
                }
            }
        }
    }

    init() {
        self.viewModel = nil
    }
}

/// Builds the map over a throwaway in-memory store whose unlock state is set by
/// hand, so each preview can pin the exact progression moment it wants.
///
/// The overwrite is the point: `GardenState.init` has a `#if DEBUG` block that
/// opens every area and every skill, which would leave the picker with nothing
/// to offer in any debug run.
@MainActor
private func forestMapPreview(areas: [String], plants: [String]) -> some View {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let gardenStore = GardenStore(context: container.mainContext)
    gardenStore.gardenState.unlockedForestAreaID = areas
    gardenStore.gardenState.unlockedPlantsID = plants
    let router = Router()

    return NavigationStack(path: Bindable(router).forestPath) {
        ForestMapView()
            .routeDestinations()
    }
    .modelContainer(container)
    .environment(gardenStore)
    .environment(router)
}

private let waterfallSkillIDs = ContentRepository.area(id: "waterfall")?.copingSkillIds ?? []

/// Fresh garden: all four areas offered, and no way to decline.
#Preview("First pick") {
    forestMapPreview(areas: [], plants: [])
}

/// Waterfall finished: the three remaining areas offered, with "Not now".
#Preview("Next pick earned") {
    forestMapPreview(areas: ["waterfall"], plants: waterfallSkillIDs)
}

/// Waterfall one plant short — the gate holds and no picker appears.
#Preview("Area unfinished") {
    forestMapPreview(areas: ["waterfall"], plants: Array(waterfallSkillIDs.dropLast()))
}
