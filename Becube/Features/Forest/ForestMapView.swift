//
//  ForestMapView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI
import SwiftData

// TODO: implement
struct ForestMapView: View {

    @Environment(GardenStore.self) private var gardenStore
    @State private var viewModel: ForestMapViewModel?
    @State private var showAreaLocked = false

    // Fixed slots on the map, one per area in areas.json order
    private let areaPositions: [CGPoint] = [
        CGPoint(x: 100, y: 200),
        CGPoint(x: 300, y: 200),
        CGPoint(x: 100, y: 600),
        CGPoint(x: 300, y: 600)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Image(ImageResource.forestMap)
                    .resizable()
                    .ignoresSafeArea()

                if let viewModel {
                    ForEach(Array(zip(viewModel.forestAreas, areaPositions)), id: \.0.id) { area, position in
                        areaNode(area, viewModel: viewModel)
                            .position(position)
                    }

                    NavigationLink {

                    } label: {
                        GoToGardenButton()
                    }
                    .position(x: 200, y: 400)

                    modals(for: viewModel)
                }
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
    @ViewBuilder
    private func areaNode(_ area: ForestArea, viewModel: ForestMapViewModel) -> some View {
        let status = (name: area.name, unlocked: viewModel.unlocked(area))

        if status.unlocked {
            NavigationLink {
                ForestAreaView(forestArea: area)
            } label: {
                AreaButton(areaStatus: status)
            }
        } else {
            Button {
                showAreaLocked = true
            } label: {
                AreaButton(areaStatus: status)
            }
            .buttonStyle(.plain)
        }
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
    ForestMapView()
        .modelContainer(container)
        .environment(GardenStore(context: container.mainContext))
}
