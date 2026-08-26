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

enum ExploreState {
    case showingPopup
    case highlightingPlant
    case completed
}

struct ForestAreaView: View {
    var viewModel: ForestAreaViewModel
    @State var currentState: ExploreState = .completed

    @Environment(GardenStore.self) private var gardenStore
    @Environment(Router.self) private var router

    // Figma artboard dimensions the designer used — positions in areas.json are in these units
    private let figmaFrame = CGSize(width: 390, height: 844)

    init(viewModel: ForestAreaViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(viewModel.backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Image(viewModel.headerImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .position(x: 200, y: 50)

                ForEach(Array(zip(viewModel.skills, viewModel.forestArea.skillPositions)), id: \.0.id) { skill, pos in
                    skillBubble(for: skill, at: pos, geo: geo)
                }

                if currentState == .showingPopup {
                    OnboardingPopupView(onLearnSkillTapped: onLearnSkillTapped)
                }
            }
            .padding(0)
        }
        .onAppear {
            if viewModel.gardenStore.gardenState.onboardingDone {
                currentState = .completed
            }
        }
    }

    func onLearnSkillTapped() {
        self.currentState = .highlightingPlant
    }

    // Pulled out of the ForEach closure: with all the position math and the ternaries
    // for onboarding/lock state inline, the compiler couldn't type-check the combined
    // expression in reasonable time.
    @ViewBuilder
    private func skillBubble(
        for skill: CopingSkill,
        at pos: ForestArea.SkillPosition,
        geo: GeometryProxy
    ) -> some View {
        let isLeft = pos.x < figmaFrame.width / 2

        // During the onboarding's highlight phase only the tutorial
        // plant stays tappable; the rest dim out of the way.
        let isTarget = (skill.id == viewModel.gardenStore.tutorialPlantID)
        let isHighlightingPhase = currentState == .highlightingPlant
        let isHighlightingTarget = isHighlightingPhase && isTarget
        let shouldDisable = isHighlightingPhase && !isTarget
        let plantArt: CopingSkill.PlantArt = viewModel.isSkillUnlocked(skill) ? .unlocked : .locked
        let plantImageName = skill.plantImageName(plantArt)

        // A bubble opens the skill's plant screen, which is where the
        // Learn and Practice choices live. Swap this for
        // `.learn(skillID:)` if a bubble should drop straight into the
        // lesson instead. The plant art sits in the same button as the
        // bubble so tapping either one opens the skill.
        Button {
            currentState = .completed
            router.push(.lockedPlant(skillID: skill.id))
        } label: {
            VStack(alignment: .tail, spacing: 24) {
                SkillBubble(
                    message: skill.name,
                    tailOffsetDenominator: isLeft ? -4 : 4
                )
                .onboardingHighlight(isActive: isHighlightingTarget)
                // The tail sits at 25%/75% of the bubble's own width (see
                // BulgingCardShape), so its x-position has to be derived the
                // same way here rather than aligned by the bubble's edge.
                .alignmentGuide(.tail) { d in isLeft ? d.width * 0.25 : d.width * 0.75 }

                Image(plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 133, height: 130)
                    .alignmentGuide(.tail) { d in d.width / 2 }
            }
        }
        .buttonStyle(.plain)
        .padding()
        .position(
            x: pos.x / figmaFrame.width * geo.size.width,
            y: pos.y / figmaFrame.height * geo.size.height
        )
        .disabled(shouldDisable)
        .opacity(shouldDisable ? 0.6 : 1.0)
        .animation(.easeInOut, value: shouldDisable)
    }
}

struct OnboardingHighlightModifier: ViewModifier {
    let isHighlighting: Bool
    
    func body(content: Content) -> some View {
        if isHighlighting {
            content
                .scaleEffect(1.1)
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .scaleEffect(1.2)
                        .opacity(0.0) // Pulses to 0 opacity
                )
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isHighlighting)
        } else {
            content
        }
    }
}

// Optional: A clean extension to make using it easier
extension View {
    func onboardingHighlight(isActive: Bool) -> some View {
        self.modifier(OnboardingHighlightModifier(isHighlighting: isActive))
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let gardenStore = GardenStore(context: container.mainContext)

    NavigationStack {
        ForestAreaView(
            viewModel: ForestAreaViewModel(
                gardenStore: gardenStore,
                forestArea: ContentRepository.areas[0]
            )
        )
    }
    .modelContainer(container)
    .environment(gardenStore)
    .environment(Router())
}
