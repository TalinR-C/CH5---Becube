//
//  GardenState.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  SwiftData @Model
//

import Foundation
import SwiftData

@Model
class GardenState {
    var name: String
    var onboardingDone: Bool = false
    var unlockedPlantsID: [String]
    var unlockedToolboxID: [String]
    var unlockedForestAreaID: [String]
    
    init(){
        self.name = ""
        self.unlockedPlantsID = []
        self.unlockedToolboxID = []
        self.unlockedForestAreaID = ["waterfall"]
//
//        // MARK: - TESTING — delete this block to restore normal progression
//        //
//        // Opens a brand-new garden with every skill and every area already
//        // unlocked, so a half-built practice can be reached straight from the
//        // Shelf instead of being earned through the forest first.
//        //
//        // `onboardingDone` has to come with it: while it is false
//        // `PracticeHostView` skips the completion screens and pops to the
//        // Garden, so finishing a practice would leave nothing to look at.
//        //
//        // This runs only when a `GardenState` is *created* — an existing store
//        // keeps whatever it already had. Delete the app from the simulator (or
//        // call `GardenStore.resetData()`) to get a fresh one.
//        //
//        // `#if DEBUG` so it cannot reach a release build even if it outlives
//        // the testing it was written for.
//        #if DEBUG
//        self.onboardingDone = true
//        self.unlockedPlantsID = ContentRepository.skills.map(\.id)
//        self.unlockedForestAreaID = ContentRepository.areas.map(\.id)
//        #endif
    }
    
}
