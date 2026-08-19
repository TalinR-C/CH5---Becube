//
//  SingleSkillPlantView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI

struct SinglePlantView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .trailing) {
                Image("Flower")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(80)

                VStack(spacing: 16) {
                    VStack {
                        Text("Done")
                        Text("x2")
                    }
                    VStack {
                        Text("Avg Rating")
                        Text("X")
                    }
                }
                .padding(.trailing)
            }

            Text("Box Breathing")
                .font(.title)

            Text("Flower Name: Hydrangea")
                .italic()

            Text("A simple breathing exercise where you breathe in, hold, breathe out, and hold again for 4 seconds each, repeated for several rounds.")

            Button("Practice") {}
            Button("Learn") {}
            Button("Reflect") {}
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "clock")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SinglePlantView()
    }
}
