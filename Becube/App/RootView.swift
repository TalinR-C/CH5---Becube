//
//  RootView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Tab bar: Forest / Garden / Toolkit / Settings
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(GardenStore.self) var gardenStore
    var body: some View {
        TabView {
            Tab("Shelf", systemImage: "book.closed.fill"){
                ShelfListView(viewModel: ShelfListViewModel(gardenStore: gardenStore))
            }
            Tab("Garden", systemImage: "garden"){
                GardenView(viewModel: GardenViewModel(gardenStore: gardenStore))
            }
            Tab("Forest", systemImage: "forest"){
                ReflectHistoryView(
                    viewModel: ReflectViewModel(gardenStore: gardenStore),
                    current: CopingSkill(
                        id: "grounding",
                        index: 8,
                        name: "Grounding",
                        image: "plant_akar_wangi",
                        plantPhilosophy: "Vetiver is grown on slopes to stop the soil washing away.",
                        info: [
                            "what": "Using your senses to pull your attention out of your head and back into the room.",
                            "how": "Name 5 things you can see\nName 4 things you can feel\nName 3 things you can hear\nName 2 things you can smell\nName 1 thing you can taste",
                            "when": "Panic, feeling unreal or detached, a memory surfacing.",
                            "why": "Attention is limited. Filling it with real things around you leaves less room for the spiral inside.\n\nThis exact exercise has not been tested on its own — it is used because clinicians consistently find it helps."
                        ],
                        plantName: "Hydrangaea"
                    ),
                )
            }
        }
    }
}

//#Preview {
//    RootView()
//}
