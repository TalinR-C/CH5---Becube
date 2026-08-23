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
