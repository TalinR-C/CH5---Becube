//
//  ReflectViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation

@Observable
class ReflectViewModel {
    private let gardenStore: GardenStore
    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
    }
    
    func submitLog(log: Log){
        gardenStore.addNewLog(log: log)
    }
}
    
