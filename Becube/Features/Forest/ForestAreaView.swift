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

    @Environment(Router.self) private var router

    // Figma artboard dimensions the designer used — positions in areas.json are in these units
    private let figmaFrame = CGSize(width: 390, height: 844)

    init(forestArea: ForestArea) {
        self.viewModel = ForestAreaViewModel(forestArea: forestArea)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("Backgrounds/\(viewModel.forestArea.id)")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Text(viewModel.areaName)
                    .font(.largeTitle)
                    .bold()
                    .position(x: 200, y: 50)

                ForEach(Array(zip(viewModel.skills, viewModel.forestArea.skillPositions)), id: \.0.id) { skill, pos in
                    // A bubble opens the skill's plant screen, which is where the
                    // Learn and Practice choices live. Swap this for
                    // `.learn(skillID:)` if a bubble should drop straight into the
                    // lesson instead.
                    Button {
                        router.push(.lockedPlant(skillID: skill.id))
                    } label: {
                        SkillBubble(
                            message: skill.name,
                            tailOffsetDenominator: pos.x < figmaFrame.width / 2 ? -4 : 4
                        )
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: pos.x / figmaFrame.width * geo.size.width,
                        y: pos.y / figmaFrame.height * geo.size.height
                    )
                }
            }
            .padding(0)
        }
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
    .environment(Router())
}
