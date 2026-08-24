//
//  ForestAreaView.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import Foundation

import SwiftUI
import SwiftData

/// Aligns a bubble's tail tip with the flower centered beneath it, regardless of
/// how wide the bubble ends up (its width varies with the skill name's text).
private struct TailAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

private extension HorizontalAlignment {
    static let tail = HorizontalAlignment(TailAlignment.self)
}

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
                    .padding(5)
                    .clipShape(.capsule)
                    .background(Color(.lightCream))
                    .position(x: 200, y: 50)
                    .foregroundStyle(.darkBrown)

                ForEach(Array(zip(viewModel.skills, viewModel.forestArea.skillPositions)), id: \.0.id) { skill, pos in
                    let isLeft = pos.x < figmaFrame.width / 2

                    // A bubble opens the skill's plant screen, which is where the
                    // Learn and Practice choices live. Swap this for
                    // `.learn(skillID:)` if a bubble should drop straight into the
                    // lesson instead.
                    VStack(alignment: .tail, spacing: 24) {
                        Button {
                            router.push(.lockedPlant(skillID: skill.id))
                        } label: {
                            SkillBubble(
                                message: skill.name,
                                tailOffsetDenominator: isLeft ? -4 : 4
                            )
                        }
                        .buttonStyle(.plain)
                        // The tail sits at 25%/75% of the bubble's own width (see
                        // BulgingCardShape), so its x-position has to be derived the
                        // same way here rather than aligned by the bubble's edge.
                        .alignmentGuide(.tail) { d in isLeft ? d.width * 0.25 : d.width * 0.75 }

                        Image("Flower")
                            .alignmentGuide(.tail) { d in d.width / 2 }
                            
                    }
                    .padding()
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
        ForestAreaView(forestArea: ContentRepository.areas[3])
    }
    .modelContainer(container)
    .environment(GardenStore(context: container.mainContext))
    .environment(Router())
}
