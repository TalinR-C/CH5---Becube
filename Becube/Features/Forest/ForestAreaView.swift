//
//  ForestAreaView.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import Foundation

import SwiftUI

struct ForestAreaView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ZStack {
            Image(ImageResource.riverbend)
                .resizable()
                .ignoresSafeArea()
            
            Text("Forest One")
                .font(.largeTitle)
                .bold()
                .position(x: 200, y: 50)
                
            Text("Hello")
                .position(x: 100, y: 200)
        }
        .padding(0)
    }
}

#Preview {
    NavigationStack {
        ForestAreaView()
    }
}
