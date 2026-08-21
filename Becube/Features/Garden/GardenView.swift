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
                
        NavigationStack(){
            HStack{
                Button{
                    viewModel.appendUnlockedPlant(id: "urge_surfing")
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

            NavigationLink("Go to List"){
                ContentView()
            }
            Text(test)
        }
       
        
//        ForEach(gardenStore.gardenState.unlockedPlantsID, id: \.self){ id in
//            let plant = ContentRepository.skills.first {$0.id == id}!
//            ZStack{
//                Image(plant.image)
//            }
//        }

    }
}

