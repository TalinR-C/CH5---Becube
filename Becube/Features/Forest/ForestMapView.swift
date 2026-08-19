//
//  ForestMapView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

// TODO: implement
struct ForestMapView: View {
    
    @Environment(\.modelContext) private var context
    @State private var viewModel: ForestMapViewModel?
    
    var body: some View {
        ZStack {
            Image(ImageResource.forestMap)
                .resizable()
                .ignoresSafeArea()
            
            if let viewModel {
                NavigationLink {
                    ForestAreaView(forestArea: viewModel.forestAreas[0])
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[0])
                }
                .disabled(!viewModel.areaStatus[0].unlocked)
                .position(x: 100, y: 200)


                NavigationLink {
                    ForestAreaView(forestArea: viewModel.forestAreas[1])
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[1])
                }
                .disabled(!viewModel.areaStatus[1].unlocked)
                .position(x: 300, y: 200)


                NavigationLink {
                    
                } label: {
                    GoToGardenButton()
                }
                .position(x: 200, y: 400)

                NavigationLink {
                    ForestAreaView(forestArea: viewModel.forestAreas[2])
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[2])
                }
                .disabled(!viewModel.areaStatus[2].unlocked)
                .position(x: 100, y: 600)

                NavigationLink {
                    ForestAreaView(forestArea: viewModel.forestAreas[3])
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[3])
                }
                .disabled(!viewModel.areaStatus[3].unlocked)
                .position(x: 300, y: 600)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ForestMapViewModel(context: context)
            }
        }
    }
    
    
    init() {
        self.viewModel = nil
    }
}

#Preview {
    NavigationStack {
        ForestMapView()
    }
}
