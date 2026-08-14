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
    private let contex: ModelContext
    var current: GardenState
    
    init(context: ModelContext) {
        self.contex = context
        let existing = try? context.fetch(FetchDescriptor<GardenState>())
        
        if let found = existing?.first {
            self.current = found
            print("Found GardenState")
        } else {
            let created = GardenState()
            context.insert(created)
            self.current = created
            print("Created GardenState")
        }
    }
    
    func appendUnlockedPlant(id: String){
        current.unlockedPlantsID.append(id)
        do{try contex.save(); print("Saved!!")} catch{print("Error saving GardenState")}
        
    }
    
    
    
    
}


