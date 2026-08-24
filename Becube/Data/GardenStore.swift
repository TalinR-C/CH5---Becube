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

        #if DEBUG
        if Self.isDemoModeEnabled {
            seedDemoData()
        }
        #endif
    }
    
    func toggleOnboarding(state: Int){
        gardenState.onboardingDone[state].toggle()
        saveData()
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
        do{
            try context.delete(model: Log.self)
            try context.delete(model: GardenState.self)
            try context.save()
            
            logHistory.removeAll()
            print("Reset Data!!")
        }
        catch{print("Error saving GardenState")}
    }

    func saveData(){
        do{try context.save(); print("Saved!!")} catch{print("Error saving GardenState")}
    }
    
    func addNewLog(log: Log){
        logHistory.append(log)
        context.insert(log)
        saveData()
        print("Added new log data + Save")
    }
    
    func getDayAverageRating(date: Date) -> Double{
        let logsInDay = logHistory.filter{$0.date.startOfDay == date.startOfDay}
        if logsInDay.count <= 0 {return 0.0}
        let ratings = logsInDay.compactMap {r in r.rating}
        let averageRating = Double(ratings.reduce(0, +)) / Double(ratings.count)
        print(date, "--- Rating:",averageRating)
        return averageRating
    }

    /// Same idea as `getDayAverageRating`, but grouped by coping skill instead of by day —
    /// this is what powers the "Done Nx" / "Avg Rating" badges on every Shelf card.
    ///
    /// Returns a tuple instead of two separate methods so a card only ever needs one call
    /// (and can't end up showing an average computed from a different log set than the count).
    /// - `average`: the mean `score` across this skill's logs that actually *have* a score.
    ///   `0` means "nothing rated yet" (either no logs, or logs with no score).
    /// - `count`: every log for this skill, rated or not — i.e. how many times it's been
    ///   practiced in total.
    func getPlantAverageRating(id: String) -> (average: Double, count: Int) {
        let logsForPlant = logHistory.filter { $0.copingID == id }
        let ratings = logsForPlant.compactMap { $0.rating }
        let averageRating = ratings.isEmpty ? 0.0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
        return (averageRating, logsForPlant.count)
    }
}

/// Maps a plant's average rating to the correct asset name for the small rating badge
/// used on every Shelf card (`ToolBoxPlantCard` and `PlantCard`). Pulled out as a free
/// function here — next to the store that computes the rating — so both card views stay
/// in sync with a single source of truth instead of duplicating the mapping logic.
enum RatingAsset {
    /// - Parameter average: `0` (nothing rated yet) returns the empty/outline icon.
    ///   Otherwise the rating is rounded *up* to the nearest whole level (3.2 -> level 4)
    ///   and clamped to the 1...5 range the `rating_color_x` assets cover.
    static func assetName(forAverage average: Double) -> String {
        guard average > 0 else { return "rating_empty_1" }
        let level = min(5, max(1, Int(average.rounded(.up))))
        return "rating_color_\(level)"
    }
}

// MARK: - Demo mode

#if DEBUG
extension GardenStore {
    /// Launch Becube with `-DemoMode` as a launch argument to boot straight into a
    /// garden that already has real skills unlocked and some fake practice history —
    /// handy for eyeballing the Shelf/Garden UI in the simulator without manually
    /// practicing skills first.
    ///
    /// To turn it on: in Xcode, pick the **Becube** scheme -> **Edit Scheme…** ->
    /// **Run** -> **Arguments** tab -> under "Arguments Passed On Launch" click **+**
    /// and add `-DemoMode`. Uncheck (rather than delete) the checkbox to turn it back
    /// off without losing it from the list.
    ///
    /// Wrapped in `#if DEBUG` so this — and the seeding code below — is compiled out
    /// of release builds entirely; it cannot run in a build you'd ship.
    static var isDemoModeEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-DemoMode")
    }

    /// Replaces whatever's currently unlocked/logged with fake-but-realistic demo data,
    /// using real skill ids from `ContentRepository` so names match real content (there's
    /// nothing to seed against if the JSON hasn't loaded any skills).
    ///
    /// Runs fresh on every launch with `-DemoMode` set, so what you see is repeatable
    /// instead of piling up more fake logs each time you relaunch — which also means it
    /// overwrites any real data in that simulator's local store. That's the point of a
    /// demo mode, but don't turn this argument on for a build you care about the data in.
    private func seedDemoData() {
//        logHistory.forEach { context.delete($0) }
//        logHistory.removeAll()
//
//        let demoSkills = Array(ContentRepository.skills.prefix(6))
//        gardenState.unlockedPlantsID = demoSkills.map(\.id)
//        gardenState.unlockedToolboxID = demoSkills.prefix(4).map(\.id)
//
//        let calendar = Calendar.current
//        for (index, skill) in demoSkills.enumerated() {
//            // Vary the practice count per skill — including one with zero logs — so the
//            // Shelf's empty-rating state is easy to spot right alongside the populated ones.
//            let practiceCount = index
//            for dayOffset in 0..<practiceCount {
//                let log = Log(
//                    id: UUID(),
//                    date: calendar.date(byAdding: .day, value: -dayOffset, to: .now) ?? .now,
//                    copingID: skill.id,
//                    rating: Int.random(in: 1...5)
//                )
//                context.insert(log)
//                logHistory.append(log)
//            }
//        }
//
//        saveData()
//        print("Demo mode: seeded \(demoSkills.count) skills, \(logHistory.count) logs")
    }
}
#endif
