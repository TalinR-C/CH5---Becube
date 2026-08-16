//
//  GardenView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

struct GardenView: View {
    @Environment(GardenStore.self) var gardenStore
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        Text(ContentRepository.skills[0].name)
        HStack{
            Button{
                gardenStore.appendUnlockedPlant(id: "test")
            } label: {
                Text("Add Plant")
            }
            Button{
                gardenStore.resetData()
            } label: {
                Text("Reset Data")
            }
        }
        
        
        
        ForEach(gardenStore.gardenState.unlockedPlantsID, id: \.self){ id in
//            let plant = ContentRepository.skills.first {$0.id == id}
//            Text("test")
            Text(id)
        }

    }
}

