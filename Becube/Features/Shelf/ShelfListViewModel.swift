//
//  ShelfListViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI


@Observable
class ShelfListViewModel {
    private let gardenStore: GardenStore
    
    var isEditing = false
    var searchText = ""
    
    init(gardenStore: GardenStore){
        self.gardenStore = gardenStore
    }
  
    var unlockedSkills: [CopingSkill] {
        let unlockedIDs = gardenStore.gardenState.unlockedPlantsID
        return ContentRepository.skills.filter { unlockedIDs.contains($0.id) }
    }
    
    var filteredSkills: [CopingSkill] {
        guard !searchText.isEmpty else { return unlockedSkills }
        return unlockedSkills.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
}
