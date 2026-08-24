//
//  GardenState.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  SwiftData @Model
//

import SwiftData

@Model
class GardenState {
    var name: String
    var onboardingDone: [Bool] = [false, false, false]
    var unlockedPlantsID: [String]
    var unlockedToolboxID: [String]
    var unlockedForestAreaID: [String]
    
    init(){
        self.name = ""
        self.unlockedPlantsID = []
        self.unlockedToolboxID = []
        self.unlockedForestAreaID = []
    }
    
}
