//
//  GardenView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

struct GardenView: View {
    @State var viewModel: GardenViewModel
    @State var test = "Hello"
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        Text(ContentRepository.skills[0].name)
                
        // The Garden tab's NavigationStack lives in RootView now — a second one
        // here would swallow every push and leave the router's path empty.
        HStack{
            Button{
                viewModel.appendUnlockedPlant(id: "urge_surfing")
            } label: {
                Text("Add Plant")
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

        NavigationLink("Go to List"){
            ContentView()
        }
        Text(test)
       
        
//        ForEach(gardenStore.gardenState.unlockedPlantsID, id: \.self){ id in
//            let plant = ContentRepository.skills.first {$0.id == id}!
//            ZStack{
//                Image(plant.image)
//            }
//        }

    }
}

