//
//  GardenStore.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  SwiftData reads/writes
//

import SwiftData

@Observable
class GardenStore {
    private let context: ModelContext
    var gardenState: GardenState
    
    init(context: ModelContext) {
        self.context = context
        let existing = try? context.fetch(FetchDescriptor<GardenState>())
        
        if let found = existing?.first {
            self.gardenState = found
            print("Found GardenState")
        } else {
            let created = GardenState()
            context.insert(created)
            self.gardenState = created
            print("Created GardenState")
        }
    }
    
    func appendUnlockedPlant(id: String){
        gardenState.unlockedPlantsID.append(id)
        do{try context.save(); print("Saved!!")} catch{print("Error saving GardenState")}
    }
    
    
    
    
}


