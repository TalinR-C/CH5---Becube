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
    var unlockedCSIds: [String] = []
    var toolBoxSkillIds: [String] = []
    var unlockedForestAreaIds: [String] = []
    
    init(name: String){
        self.name = ""
        self.unlockedCSIds = []
        self.toolBoxSkillIds = []
        self.unlockedForestAreaIds = []
    }
    
}
