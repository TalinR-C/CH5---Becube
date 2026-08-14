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

struct RootView {
    var body: some View {
        TabView {
            NavigationStack {
                ShelfListView()
            }
            .tabItem {
                Label("Shelf", systemImage: "book.closed.fill")
            }
            GardenView()
                .tabItem {
                    Label("Garden", systemImage: "garden")
                }
            NavigationStack {
                ForestAreaView()
            }
            .tabItem {
                Label("Forest", systemImage: "forest")
            }
        }
    }
}
