//
//  ForestAreaView.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import Foundation

import SwiftUI
import SwiftData

struct ForestAreaView: View {
    private let viewModel: ForestAreaViewModel

    @Environment(GardenStore.self) private var gardenStore

    // Fixed slots for up to four skill bubbles, alternating left/right
    private let bubblePositions: [CGPoint] = [
        CGPoint(x: 100, y: 200),
        CGPoint(x: 300, y: 250),
        CGPoint(x: 100, y: 400),
        CGPoint(x: 300, y: 500)
    ]

    init(forestArea: ForestArea) {
        self.viewModel = ForestAreaViewModel(forestArea: forestArea)
    }

    var body: some View {
        ZStack {
            Image(viewModel.forestArea.id)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                

            Text(viewModel.areaName)
                .font(.largeTitle)
                .bold()
                .position(x: 200, y: 100)

            ForEach(Array(zip(viewModel.skills, bubblePositions)), id: \.0.id) { skill, position in
                NavigationLink {
                    LearnView(
                        viewModel: LearnViewModel(skillID: skill.id, gardenStore: gardenStore)
                    )
                } label: {
                    SkillBubble(
                        message: skill.name,
                        tailOffsetDenominator: position.x < 200 ? -4 : 4
                    )
                }
                .buttonStyle(.plain)
                .position(position)
            }
        }
        .padding(0)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    NavigationStack {
        ForestAreaView(forestArea: ContentRepository.areas[0])
    }
    .environment(GardenStore(context: container.mainContext))
}
