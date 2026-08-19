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
    @Environment(GardenStore.self) private var gardenStore
    
    var body: some View {
        TabView {
            ShelfListView(gardenStore: gardenStore)
            .tabItem {
                Label("Shelf", systemImage: "book.closed.fill")
            }
            GardenView()
            .tabItem {
                Label("Garden", systemImage: "garden")
            }
            ForestAreaView()
            .tabItem {
                Label("Forest", systemImage: "forest")
            }
        }
    }
}

#Preview {
    RootView()
}
