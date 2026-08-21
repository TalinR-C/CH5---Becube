//
//  ReflectViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

struct Day: Hashable{
    var date: Date
    var averageRating: Double?
    var hasEntry: Bool = false
    init(date: Date, averageRating: Double? = nil, hasEntry: Bool) {
        self.date = date
        self.averageRating = averageRating
        self.hasEntry = hasEntry
    }
}

@Observable
class ReflectViewModel {
    private let gardenStore: GardenStore
    let current: CopingSkill
    var logs: [Log] = []
    var currentRatingClass: Int {
        return getRatingClass(rating: getPlantAverageRating())
    }
    
    init(gardenStore: GardenStore, current: CopingSkill) {
        self.gardenStore = gardenStore
        self.current = current
        
        // populate log array with default values. Set data to current day.
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == current.id}
        self.logs = plantLogs.filter{$0.date.startOfDay == .now.startOfDay}
    }
    
    func submitLog(log: Log){
        gardenStore.addNewLog(log: log)
    }
    
    func getCurrentPlantlogs() -> [Log]{
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == current.id}
        return plantLogs
    }
    
    func getDayLogs(day: Date){
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == self.current.id}
        self.logs = plantLogs.filter{$0.date.startOfDay == day.startOfDay}
    }
    
    func doesDayHaveLogEntries(day: Date) -> Bool{
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == self.current.id}
        return plantLogs.contains(where: {$0.date.startOfDay == day.startOfDay})
    }
    
    private func getPlantAverageRating() -> Double{
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == current.id}
        if plantLogs.count <= 0 {return 0.0}
        let ratings = plantLogs.compactMap {r in r.rating}
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        return averageRating
    }
    
    func ratingName(rating: Int) -> String {
        if rating == 0 {return "No Rating Please Check"}
        let ratingName = ["Not For \nMe", "Not Quite", "It's Okay", "I Like It", "I Really \nLike It"]
        return String(ratingName[rating - 1])
    }
    
    func getRatingClass(rating: Double) -> Int {
        if rating == 0.0 {return 0}
        if rating <= 1.0 {return 1 }
        if rating <= 2.0 {return 2 }
        if rating <= 3.0 {return 3 }
        if rating <= 4.0 {return 4 }
        return 5
    }
    
    func resetEverything(){
        gardenStore.resetData()
    }
}
    
