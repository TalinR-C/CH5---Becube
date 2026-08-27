//
//  SelfSoothingView.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 26/08/26.
//

import SwiftUI

struct SelfSoothingView: View {
    /// `@Bindable` rather than the plain `let` the timed practices use: every
    /// field on this screen writes back into the ViewModel. Owned by
    /// `PracticeHostView` — `@State` here would fight the host for ownership,
    /// and the host is what reads the worksheet back at completion.
    @Bindable var viewModel: SelfSoothingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Write down 2–3 things for each sense that would help you feel calmer.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.darkBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                senseSection(title: "Sense of Sight", icon: "eye", entry: $viewModel.sightEntry)
                senseSection(title: "Sense of Hearing", icon: "ear", entry: $viewModel.hearingEntry)
                senseSection(title: "Sense of Smell", icon: "wind", entry: $viewModel.smellEntry)
                senseSection(title: "Sense of Taste", icon: "fork.knife", entry: $viewModel.tasteEntry)
                senseSection(title: "Sense of Touch", icon: "hand.raised", entry: $viewModel.touchEntry)
            }
            .padding(.bottom, 20)
        }
    }

    private func senseSection(title: String, icon: String, entry: Binding<SenseEntry>) -> some View {
        CommentBox(bulge: 6, tailPosition: .none, contentPadding: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: icon)
                    .font(.custom("Jua-Regular", size: 17))
                    .foregroundStyle(.darkBrown)

                numberedField(number: 1, text: entry.item1)
                numberedField(number: 2, text: entry.item2)
                numberedField(number: 3, text: entry.item3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Other ideas")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    TextField("", text: entry.otherIdeas, axis: .vertical)
                        .lineLimit(1...3)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                }
            }
        }
    }

    private func numberedField(number: Int, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Text("\(number).")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.darkBrown)
                .frame(width: 18, alignment: .leading)

            TextField("Something calming…", text: text)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
        }
    }
}

#Preview {
    SelfSoothingView(viewModel: SelfSoothingViewModel(skillID: "self_soothing"))
}
