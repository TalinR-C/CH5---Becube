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
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        
        if(gardenStore.gardenState.onboardingDone == false){
            NavigationStack(path: $router.forestPath) {
                ForestAreaView(viewModel: ForestAreaViewModel(gardenStore: gardenStore, forestArea: ContentRepository.area(id: "field")!))
                    .routeDestinations()
            }
        }
        else {
            TabView(selection: $router.selectedTab) {
                NavigationStack(path: $router.shelfPath) {
                  ShelfListView(viewModel: ShelfListViewModel(gardenStore: gardenStore))
                        .routeDestinations()
                        .tabBarVisible(router.shelfPath.isEmpty)
                }
                .tabItem {
                    Image(ImageResource.shelfIcon)
                    Text("Shelf")
                }
                .tag(AppTab.shelf)
                
                NavigationStack(path: $router.gardenPath) {
                  GardenView(viewModel: GardenViewModel(gardenStore: gardenStore))
                        .routeDestinations()
                        .tabBarVisible(router.gardenPath.isEmpty)
                }
                .tabItem {
                    Image(ImageResource.gardenIcon)
                    Text("Garden")
                }
                .tag(AppTab.garden)
                
                NavigationStack(path: $router.forestPath) {
                    ForestMapView()
                        .routeDestinations()
                        .tabBarVisible(router.forestPath.isEmpty)
                }
                .tabItem{
                    Image(systemName: "map.fill")
                    Text("Explore")
                }
                .tag(AppTab.forest)
                
            }
            .tint(.darkBrown)
        }
    }
}

private extension View {
    /// Declares tab-bar visibility on the *root* of a stack, derived from
    /// whether that stack has anything pushed.
    ///
    /// `RouteDestinations` also hides the bar per-destination, and the two
    /// always agree — but a destination's preference is only discovered a
    /// render pass after the transition begins, which is what makes the bar
    /// fade in late on the way back. `path.isEmpty` flips in the same
    /// transaction as the push, so SwiftUI knows before the animation starts.
    func tabBarVisible(_ isVisible: Bool) -> some View {
        toolbar(isVisible ? .visible : .hidden, for: .tabBar)
    }
}
