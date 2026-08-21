//
//  ReflectViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

@Observable
class ReflectViewModel {
    private let gardenStore: GardenStore
    let current: CopingSkill
    var logs: [Log] = []
    var ratingClassImage: Image {
        return getRatingClassImage(rating: getPlantAverageRating())
    }
    
    init(gardenStore: GardenStore, current: CopingSkill) {
        self.gardenStore = gardenStore
        self.current = current
        getDefaultLogs(plant: current)
    }
    
    func submitLog(log: Log){
        gardenStore.addNewLog(log: log)
    }
    
    func getDefaultLogs(plant: CopingSkill){
        // the default logs are ones of this specific plant
        // and filtered to the current day.
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == plant.id}
        self.logs = plantLogs.filter{$0.date.startOfDay == .now.startOfDay}
    }
    
    func getDayLogs(day: Date){
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == self.current.id}
        self.logs = plantLogs.filter{$0.date.startOfDay == day.startOfDay}
    }
    
    func ratingName(rating: Int) -> String {
        let ratingName = ["Not For \nMe", "Not Quite", "It's Okay", "I Like It", "I Really \nLike It"]
        return String(ratingName[rating - 1])
    }
    
    private func getPlantAverageRating() -> Double{
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == current.id}
        if plantLogs.count <= 0 {return 0.0}
        let ratings = plantLogs.compactMap {r in r.rating}
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        return averageRating
    }
    
    private func getRatingClassImage(rating: Double) -> Image{
        // TODO: What if PlantAverageRating is 0? If it's 0 it doesn't have a rating.
        if rating == 0.0 {return Image("")}
        if rating <= 1.0 {return Image("rating_1")}
        if rating <= 2.0 {return Image("rating_2")}
        if rating <= 3.0 {return Image("rating_3")}
        if rating <= 4.0 {return Image("rating_4")}
        return Image("rating_5")
    }
    
    func resetEverything(){
        gardenStore.resetData()
    }
}
    
