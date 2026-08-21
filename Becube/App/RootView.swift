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
            ShelfListView(viewModel: ShelfListViewModel(gardenStore: gardenStore))
                .tabItem {
                    Image(ImageResource.shelfIcon)
                    Text("Shelf")
                }
            GardenView(viewModel: GardenViewModel(gardenStore: gardenStore))
                .tabItem {
                    Image(ImageResource.gardenIcon)
                    Text("Garden")
                }
            ForestMapView()
                .tabItem{
                    Image(systemName: "map.fill")
                    Text("Explore")
                }
        }
        .tint(.darkBrown)
    }
}

//#Preview {
//    RootView()
//}
