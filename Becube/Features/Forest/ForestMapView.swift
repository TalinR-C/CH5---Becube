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
            Image(ImageResource.riverbend)
                .resizable()
                .ignoresSafeArea()
            
            if let viewModel {
                NavigationLink {
                    
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[0])
                        .position(x: 100, y: 200)
                }
                
                
                NavigationLink {
                    
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[1])
                        .position(x: 300, y: 200)
                }
                
                
                NavigationLink {
                    
                } label: {
                    GoToGardenButton()
                        .position(x: 200, y: 400)
                }
                
                NavigationLink {
                
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[2])
                        .position(x: 100, y: 600)
                }
                
                Button {
                    
                } label: {
                    AreaButton(areaStatus: viewModel.areaStatus[3])
                        .position(x: 300, y: 600)
                }
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
    ForestMapView()
}
