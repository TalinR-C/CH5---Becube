//
//  ForestAreaView.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import Foundation

import SwiftUI
import SwiftData

enum ExploreState {
    case showingPopup
    case highlightingPlant
    case completed
}

struct ForestAreaView: View {
    var viewModel: ForestAreaViewModel
    @State var currentState: ExploreState = .showingPopup

    @Environment(Router.self) private var router
    

    // Fixed slots for up to four skill bubbles, alternating left/right
    private let bubblePositions: [CGPoint] = [
        CGPoint(x: 100, y: 200),
        CGPoint(x: 300, y: 250),
        CGPoint(x: 100, y: 400),
        CGPoint(x: 300, y: 500)
    ]

    init(viewModel: ForestAreaViewModel) {
        self.viewModel = viewModel
        if viewModel.gardenStore.gardenState.onboardingDone[0] == true {
            currentState = .completed
        }
    }

    var body: some View {
        ZStack {
            Image(ImageResource.riverbend)
                .resizable()
                .ignoresSafeArea()

            Text(viewModel.areaName)
                .font(.largeTitle)
                .bold()
                .position(x: 200, y: 50)

            ForEach(Array(zip(viewModel.skills, bubblePositions)), id: \.0.id) { skill, position in
                
                // 1. DEFINE THE LOGIC HERE
                // Example: Make the very first skill in your array the target
                let isTarget = (skill.id == viewModel.skills.first?.id)
                
                // Example: Check your view's state to see if we are currently highlighting
                // (Replace `currentState == .highlighting` with however your app tracks onboarding)
                let isHighlightingPhase = currentState == .highlightingPlant ? true : false
                // 2. USE THEM TO CALCULATE BEHAVIOR
                let isHighlightingTarget = isHighlightingPhase && isTarget
                let shouldDisable = isHighlightingPhase && !isTarget
                
                // Calculate this BEFORE the view builder to prevent compiler timeouts
                let tailOffset: CGFloat = position.x < 200 ? -4.0 : 4.0
                
                Button {
                    // Optional: progress your onboarding state when they click the target
                    // if isHighlightingTarget { currentState = .nextStep }
                    currentState = .completed
                    router.push(.lockedPlant(skillID: skill.id))
                } label: {
                    SkillBubble(
                        message: skill.name,
                        tailOffsetDenominator: tailOffset
                    )
                    // Apply the custom modifier from the previous step
                    .onboardingHighlight(isActive: isHighlightingTarget)
                }
                .buttonStyle(.plain)
                .position(position)
                .disabled(shouldDisable)
                .opacity(shouldDisable ? 0.6 : 1.0)
                // Optional: animate the dimming effect
                .animation(.easeInOut, value: shouldDisable)
            }
            
            if(currentState == .showingPopup){
                OnboardingPopupView(onLearnSkillTapped: onLearnSkillTapped)
            }
            
        }
        .padding(0)
        
    }
    func onLearnSkillTapped(){
        self.currentState = .highlightingPlant
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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GardenState.self,
            Log.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    let gardenStore = GardenStore(context: sharedModelContainer.mainContext)
    
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    NavigationStack {
        ForestAreaView(viewModel: ForestAreaViewModel(gardenStore: gardenStore, forestArea: ContentRepository.areas[0]))
    }
    .environment(GardenStore(context: container.mainContext))
    .environment(Router())
}
