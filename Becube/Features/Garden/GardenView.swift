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
}

