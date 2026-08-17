//
//  ForestMapViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI
import SwiftData

// TODO: implement

@Observable
class ForestMapViewModel {
    var columns: [GridItem]
    var forestAreas: [ForestArea]
    var garden: GardenState?
    var context: ModelContext
    
    var areaStatus: [(name: String, unlocked: Bool)] {
        forestAreas.map { ($0.name, (garden?.unlockedForestAreaID.contains($0.id) ?? false)) }
    }
    
    init(context: ModelContext) {
        self.columns = [
            .init(.flexible(), spacing: 0, alignment: .center),
            .init(.flexible(), spacing: 0, alignment: .center)
        ]
        
        self.forestAreas = Bundle.main.decode([ForestArea].self, from: "areas.json")
        self.context = context
        
        // Fetch or create GardenState singleton
        let existing = try? context.fetch(FetchDescriptor<GardenState>())
        if let found = existing?.first {
            self.garden = found
        } else {
            let created = GardenState()
            context.insert(created)
            self.garden = created
        }

        unlockFirstAreaIfNeeded()
    }

    // The first area is always available; unlock it for fresh gardens
    private func unlockFirstAreaIfNeeded() {
        guard let garden,
              let firstArea = forestAreas.min(by: { $0.index < $1.index }),
              !garden.unlockedForestAreaID.contains(firstArea.id) else { return }

        garden.unlockedForestAreaID.append(firstArea.id)
    }
    
    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        return garden?.unlockedForestAreaID.contains(area.id) ?? false
    }
    
    func fetchData() {
        let descriptor = FetchDescriptor<GardenState>()
        
        do {
            if let found = try context.fetch(descriptor).first {
                garden = found
            } else {
                let created = GardenState()
                context.insert(created)
                garden = created
            }
            unlockFirstAreaIfNeeded()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
}
