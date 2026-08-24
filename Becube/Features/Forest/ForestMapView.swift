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

    // Fixed slots on the map, one per area in areas.json order
    private let areaPositions: [CGPoint] = [
        CGPoint(x: 100, y: 200),
        CGPoint(x: 300, y: 200),
        CGPoint(x: 100, y: 600),
        CGPoint(x: 300, y: 600)
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

    /// The picker takes priority: until the user has chosen somewhere to start,
    /// every area is locked and the locked modal would be all they could reach.
    @ViewBuilder
    private func modals(for viewModel: ForestMapViewModel) -> some View {
        if viewModel.needsStartingArea {
            AreaPickerModal(areas: viewModel.forestAreas) { area in
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.chooseStartingArea(area)
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

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let gardenStore = GardenStore(context: container.mainContext)
    let router = Router()

    NavigationStack(path: Bindable(router).forestPath) {
        ForestMapView()
            .routeDestinations()
    }
    .modelContainer(container)
    .environment(gardenStore)
    .environment(router)
}
