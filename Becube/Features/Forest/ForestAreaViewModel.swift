//
//  ForestAreaViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftData

// TODO: implement

@Observable
class ForestAreaViewModel {
    var skills: [CopingSkill]
    
    init(skills: [CopingSkill]) {
        self.skills = []
        
        self.skills = Bundle.main.decode([CopingSkill].self, from: "skills_en")
    }
}
