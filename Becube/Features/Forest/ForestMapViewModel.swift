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
    var areaStatus: [(name: String, isLocked: Bool)]
    var garden: GardenState?
    var context: ModelContext
    
    init(context: ModelContext) {
        self.columns = [
            .init(.flexible(), spacing: 0, alignment: .center),
            .init(.flexible(), spacing: 0, alignment: .center)
        ]
        
        self.forestAreas = Bundle.main.decode([ForestArea].self, from: "areas.json")
        
        self.areaStatus = [(String, Bool)]()
        
        self.context = context
        
        self.garden =
        
        self.areaStatus = forestAreas.map{($0.name, garden.unlockedForestAreaID.contains($0.id))}
    }
    
    // To check whether a particular area is unlocked
    func unlocked(_ area: ForestArea) -> Bool {
        return garden?.unlockedForestAreaID.contains(area.id) ?? false
    }
    
    func fetchData() {
            let descriptor = FetchDescriptor<GardenState>()
            
            do {
                garden = try context.fetch(descriptor)
            } catch {
                print("Failed to fetch items: \(error)")
            }
        }
}
