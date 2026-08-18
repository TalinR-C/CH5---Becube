//
//  SingleSkillPlantView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftData
import SwiftUI

struct SingleSkillPlantView: View {
    @State var viewModel: SingleSkillPlantViewModel

    var body: some View {
        VStack(spacing: 16) {
    

            if viewModel.isGrown {
                HStack {
                    VStack { Text("Done"); Text("\(viewModel.practiceCount)x") }
                    VStack { Text("Avg Rating"); Text(viewModel.averageRating.map { String(format: "%.1f", $0) } ?? "—") }
                }
                Button("Practice") { }
                Button("Learn") { }
                Button("Reflect") { }
            } else {
                Button("Learn") { }
                Button("Jump Straight to Practice") { }
            }
        }
        .task {
            viewModel.load()
        }
    }
}

#Preview("First Time - Not Grown") {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let viewModel = SingleSkillPlantViewModel(
        skillID: "grounding",
        modelContext: container.mainContext
    )
    return SingleSkillPlantView(viewModel: viewModel)
        .modelContainer(container)
}


