//
//  GardenViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation

@Observable
class GardenViewModel {
    private let gardenStore: GardenStore
    
    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
    }

    /// The text on the hanging sign, mirroring `ShelfListViewModel.shelfTitle` so the two
    /// tabs read the same way — and falling back to a neutral title until the garden has
    /// been named in onboarding.
    var gardenTitle: String {
        let name = gardenStore.gardenState.name
        return name.isEmpty ? "My Garden" : "\(name)'s Garden"
    }
    
    func appendUnlockedPlant(id: String){
        gardenStore.unlockPlant(id: id)
    }
    
    func resetPlantData(){
        gardenStore.gardenState.unlockedPlantsID.removeAll()
        gardenStore.saveData()
    }
    
    func nuclearReset(){
        gardenStore.resetData()
    }
    
    func testGardenVM(){
        print("GArden test")
    }
}
