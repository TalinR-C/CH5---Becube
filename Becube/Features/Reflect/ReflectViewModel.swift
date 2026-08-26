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
    /// Set when reflection follows a practice: the log to fill in rather than
    /// duplicate. `nil` when the user came straight here, so this reflection is
    /// a log in its own right.
    private let attachedLogID: UUID?
    let current: CopingSkill
    var logs: [Log] = []
    var currentRatingClass: Int {
        return getRatingClass(rating: getPlantAverageRating())
    }
    
    init(gardenStore: GardenStore, current: CopingSkill, attachingTo logID: UUID? = nil) {
        self.gardenStore = gardenStore
        self.current = current
        self.attachedLogID = logID
        
        // populate log array with default values. Set data to current day.
        let plantLogs = gardenStore.logHistory.filter{$0.copingID == current.id}
        self.logs = plantLogs.filter{$0.date.startOfDay == .now.startOfDay}
    }
    
    /// What the log being attached to already says, if anything.
    ///
    /// A practice can write to the log before the user ever reaches this screen —
    /// STOP's Observe step does. Saving a reflection assigns `journal`
    /// unconditionally, so without seeding the text box from this, submitting an
    /// empty reflection would quietly erase what the user wrote during practice.
    var existingJournal: String? {
        attachedLogID.flatMap { gardenStore.log(id: $0)?.journal }
    }

    /// `rating` is `nil` when the user didn't pick one — an unrated log still
    /// counts as a use of the skill, it just stays out of the average.
    func submitLog(rating: Int?, journal: String?) {
        ReflectionService.save(
            rating: rating,
            journal: journal,
            skillID: current.id,
            attachingTo: attachedLogID,
            in: gardenStore
        )
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
    
    func ratingName(rating: Int, withNewline: Bool = false) -> String {
        if rating == 0 {return "No Rating Please Check"}
        let ratingNameNewline = ["Not For \nMe", "Not Quite", "It's Okay", "I Like It", "I Really \nLike It"]
        let ratingName = ["Not For Me", "Not Quite", "It's Okay", "I Like It", "I Really Like It"]
        
        if(withNewline){return String(ratingNameNewline[rating - 1])}
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
    
