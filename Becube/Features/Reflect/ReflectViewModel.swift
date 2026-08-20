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
    var displayedLogs: [Log] = []
    
    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
    }
    
    func submitLog(log: Log){
        gardenStore.addNewLog(log: log)
    }
    
    func ratingName(rating: Int) -> String {
        let ratingName = ["Not For \nMe", "Not Quite", "It's Okay", "I Like It", "I Really \nLike It"]
        return String(ratingName[rating - 1])
    }
}
    
