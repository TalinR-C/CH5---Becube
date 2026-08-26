//
//  GardenView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

enum GardenOnboarding {
    case discoverSkills // Screen 9
    case nameGarden     // Screen 10
    case complete       // Done
}

struct GardenView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(Router.self) private var router
    @State var gardenName: String = ""
    @State var viewModel: GardenViewModel
    @State var test = "Hello"
    @State var currentOnboardingStep = GardenOnboarding.discoverSkills
    
    var body: some View {
        ZStack{
            // Full-bleed, behind the status bar and the tab bar alike. The explicit
            // frame is what keeps `scaledToFill` from sizing the ZStack itself: the
            // artwork overflows its frame to cover the screen, but still reports the
            // screen's size to the stack around it.
            Image("GardenBack")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            
            Group{
                Image("urge_surfing_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "urge_surfing") ? 1 : 0)
                Image("problem_solving_steps_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "problem_solving_steps") ? 1 : 0)
                Image("expressive_writing_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "expressive_writing") ? 1 : 0)
                Image("grounding(5-4-3-2-1)_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "grounding") ? 1 : 0)
                Image("tipp_skill_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "tipp_skill") ? 1 : 0)
                Image("box_breathing_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "box_breathing") ? 1 : 0)
                Image("body_scan_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "body_scan") ? 1 : 0)
                Image("if_then_planning_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "if_then_planning") ? 1 : 0)
                Image("stop_skill_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "stop_skill") ? 1 : 0)
                Image("behavioural_activation_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "behavioral_activation") ? 1 : 0)
                Image("cognitive_reframing_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "cognitive_reframing") ? 1 : 0)
                Image("radical_acceptance_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "radical_acceptance") ? 1 : 0)
                Image("opposite_action_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "opposite_action") ? 1 : 0)
                Image("self_soothing_5_senses_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "self_soothing") ? 1 : 0)
                Image("progressive_muscle_relax_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "progressive_muscle_relaxation") ? 1 : 0)
                Image("halt_check_in_bg")
                    .resizable()
                    .scaledToFill()
                    .opacity(isUnlocked(id: "halt_check_in") ? 1 : 0)
            }
            .ignoresSafeArea()
            
            if gardenStore.gardenState.onboardingDone == false{
                if currentOnboardingStep == .discoverSkills{
                    ZStack{
                        Rectangle()
                            .opacity(0.3)
                            .onTapGesture {}
                            .ignoresSafeArea()
                        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
                            VStack{
                                Text("Discover More Skills")
                                    .foregroundStyle(Color.darkBrown).bold()
                                Text("The more you learn, the more the garden grows")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(Color.brown)
                                    .padding()
                                Button("Next"){
                                    currentOnboardingStep = .nameGarden
                                }
                            }
                            .frame(width: 300, height: 250)
                            .background(.white)
                        }
                    }
                }
                else if currentOnboardingStep == .nameGarden{
                    ZStack{
                        Rectangle()
                            .opacity(0.3)
                            .onTapGesture {}
                            .ignoresSafeArea()
                        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
                            VStack{
                                Text("Name Your Garden")
                                    .foregroundStyle(Color.darkBrown).bold()
                                TextField("Enter Name", text: $gardenName)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                Button("Continue"){
                                    gardenStore.updateGardenName(name: gardenName)
                                    currentOnboardingStep = .complete
                                    router.popToRoot()
                                    router.selectedTab = .shelf
                                }
                            }
                            .frame(width: 300, height: 250)
                            .background(.white)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .titleSign(viewModel.gardenTitle)
        // Same reasoning as ShelfListView: a navigation bar would reserve a strip of
        // height above the sign's ropes and lay its material over the background.
        .toolbar(.hidden, for: .navigationBar)
    }
    
    func isUnlocked(id: String) -> Bool{
        return gardenStore.gardenState.unlockedPlantsID.contains(id)
    }
}

