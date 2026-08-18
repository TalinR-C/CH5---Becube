//
//  GardenViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation

@Observable
class GardenViewModel {
    @ObservationIgnored weak var gardenStore: GardenStore?
    
    init() {
        print("YAAY")
    }
    
    func resetData(){
        gardenStore!.gardenState.unlockedPlantsID.removeAll()
        gardenStore!.saveData()
    }
    
    func testGardenVM(){
        print("GArden test")
    }
}
