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
    var body: some View {
        TabView {
            ShelfListView()
            .tabItem {
                Label("Shelf", systemImage: "book.closed.fill")
            }
            GardenView()
            .tabItem {
                Label("Garden", systemImage: "garden")
            }
            
            ForestMapView()
            .tabItem {
                Label("Forest", systemImage: "forest")
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    RootView()
        .modelContainer(container)
        .environment(GardenStore(context: container.mainContext))
}
