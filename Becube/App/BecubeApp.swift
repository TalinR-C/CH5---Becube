//
//  BecubeApp.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

@main
struct BecubeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GardenState.self,
            Log.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var gardenStore : GardenStore {
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(gardenStore)
    }
}
