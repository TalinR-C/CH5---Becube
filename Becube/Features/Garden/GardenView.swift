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
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    
            NavigationStack(){
                HStack{
                    Button{
                        viewModel.appendUnlockedPlant(id: "box_breathing")
                    } label: {
                        Text("Add Plant")
                    }
                    Button{
                        viewModel.nuclearReset()
                    } label: {
                        Text("Reset Data")
                    }
                    Button{
                        viewModel.testGardenVM()
                    } label: {
                        Text("Test Garden")
                    }
                    Button("Change Data"){
                        test = "World"
                    }
                }
                Button{
                    viewModel.resetPlantData()
                } label: {
                    Text("Reset Data")
                }
                Button{
                    viewModel.testGardenVM()
                } label: {
                    Text("Test Garden")
                }
                Button("Change Data"){
                    test = "World"
                }
            }
            .toolbar(gardenStore.gardenState.onboardingDone ? .hidden : .visible, for: .tabBar)

            NavigationLink("Go to List"){
                ContentView()
            }
            Text(test)
           
            
            ForEach(gardenStore.gardenState.unlockedPlantsID, id: \.self){ id in
                let plant = ContentRepository.skill(id: id)
                ZStack{
                    Image(plant!.image)
                }
            }
            
            if gardenStore.gardenState.onboardingDone == false{
                if currentOnboardingStep == .discoverSkills{
                    ZStack{
                        Rectangle()
                            .opacity(0.3)
                            .onTapGesture {}
                            .ignoresSafeArea()
                        VStack{
                            Text("Discover More Skills")
                            Text("The more you learn, the more the garden grows")
                            Button("Next"){
                                currentOnboardingStep = .nameGarden
                            }
                        }
                        .frame(width: 300, height: 250)
                        .background(.white)
                    }
                }
                else if currentOnboardingStep == .nameGarden{
                    ZStack{
                        Rectangle()
                            .opacity(0.3)
                            .onTapGesture {}
                            .ignoresSafeArea()
                        VStack{
                            Text("Name Your Garden")
                            TextField("Enter Name", text: $gardenName)
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
}

