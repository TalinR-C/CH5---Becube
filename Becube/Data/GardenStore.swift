//
//  GardenStore.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  SwiftData reads/writes
//

import SwiftData
import Foundation

@Observable
class GardenStore {
    private let context: ModelContext
    var gardenState: GardenState
    var logHistory: [Log]
    
    init(context: ModelContext) {
        self.context = context
        let existing = try? context.fetch(FetchDescriptor<GardenState>())
        
        if let found = existing?.first {
            self.gardenState = found
            print("Found GardenState")
        } else {
            let created = GardenState()
            context.insert(created)
            self.gardenState = created
            print("Created GardenState")
        }
        
        let existingLogs = try? context.fetch(FetchDescriptor<Log>())
        if let foundLogs = existingLogs {
            self.logHistory = foundLogs
            print("Found Logs")
        } else {
            self.logHistory = []
            print("Created empty Logs")
        }
        
        print("initialize gardenviewmodel")
    }
    
    // MARK: - Unlocking

    /// Whether this skill's plant is already in the garden.
    func hasUnlockedPlant(id: String) -> Bool {
        gardenState.unlockedPlantsID.contains(id)
    }

    /// Grants a skill's plant. No-op (and no write) if it is already unlocked.
    /// Returns whether this call actually unlocked something.
    @discardableResult
    func unlockPlant(id: String) -> Bool {
        guard let updated = Progression.unlocking(id, in: gardenState.unlockedPlantsID) else {
            return false
        }
        gardenState.unlockedPlantsID = updated
        saveData()
        return true
    }

    /// Whether this forest area is open to the user.
    func hasUnlockedForestArea(id: String) -> Bool {
        gardenState.unlockedForestAreaID.contains(id)
    }

    /// Opens a forest area. No-op (and no write) if it is already unlocked.
    /// Returns whether this call actually unlocked something.
    @discardableResult
    func unlockForestArea(id: String) -> Bool {
        guard let updated = Progression.unlocking(id, in: gardenState.unlockedForestAreaID) else {
            return false
        }
        gardenState.unlockedForestAreaID = updated
        saveData()
        return true
    }

    func resetData(){
        gardenState.unlockedPlantsID.removeAll()
        do{try context.save(); print("Saved!!")} catch{print("Error saving GardenState")}
    }
    
    func saveData(){
        do{try context.save(); print("Saved!!")} catch{print("Error saving GardenState")}
    }
    
    func getDayAverageRating(date: Date) -> Double{
        let logsInDay = logHistory.filter{$0.date.startOfDay == date.startOfDay}
        if logsInDay.count <= 0 {return 0.0}
        let ratings = logsInDay.compactMap {r in r.score}
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        print(date, "--- Rating:",averageRating)
        return averageRating
    }
    
    
}


