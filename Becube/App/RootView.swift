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
–––    @Environment(GardenStore.self) var gardenStore
    var body: some View {
        TabView {
            Tab("Shelf", systemImage: "book.closed.fill"){
                ShelfListView()
            }
            Tab("Garden", systemImage: "garden"){
                GardenView(viewModel: GardenViewModel(gardenStore: gardenStore))
            }
            Tab("Forest", systemImage: "forest"){
                ForestAreaView()
            }
        }
    }
}

//#Preview {
//    RootView()
//}
