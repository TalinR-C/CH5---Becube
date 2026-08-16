//
//  GardenView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI

struct GardenView: View {
    @Environment(GardenStore.self) var gardenStore
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text(ContentRepository.skills[0].name)
        Button{
            gardenStore.appendUnlockedPlant(id: "test")
        } label: {
            Text("Add Plant")
        }

    }
}

#Preview {
    GardenView()
}
