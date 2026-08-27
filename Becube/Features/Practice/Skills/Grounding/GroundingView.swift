//
//  GroundingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct GroundingView: View {

    /// Owned by `PracticeHostView`. A plain `let`: `@Observable` still drives
    /// re-renders, and `@State` here would fight the host for ownership.
    let viewModel: GroundingViewModel

    var body: some View {
        VStack(spacing: 26) {
            LetterProgress(
                letters: SenseStage.letters,
                currentIndex: viewModel.currentStage.rawValue,
                completed: viewModel.completedIndices,
                onTap: { index in
                    guard let stage = SenseStage(rawValue: index) else { return }
                    viewModel.select(stage)
                }
            )

            senseCard
            counter
        }
        .animation(.snappy, value: viewModel.currentStage)
        .animation(.snappy, value: viewModel.noticed)
        // Fires on every tap, and again when a filled stage resets to zero —
        // both are moments worth feeling.
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.noticed)
    }

    // MARK: - Pieces

    private var senseCard: some View {
        CommentBox(bulge: 6, contentPadding: 20) {
            VStack(spacing: 10) {
                Image(systemName: viewModel.currentStage.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color.darkBrown)

                Text(viewModel.currentStage.title)
                    // Jua has a single weight, so no `.bold()` — it would be
                    // synthesised rather than drawn.
                    .font(.custom("Jua-Regular", size: 22))
                    .foregroundStyle(Color.darkBrown)
                    .multilineTextAlignment(.center)

                Text(viewModel.currentStage.prompt)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    // Without this a wrapping line gets truncated inside a card.
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 240)
        }
    }

    /// The whole block is one tap target, not five small ones.
    ///
    /// Nobody mid-panic should have to aim at a 20pt dot — the dots are what
    /// the eye gets, the block is what the finger gets, and a tap anywhere in
    /// it counts one.
    private var counter: some View {
        Button(action: viewModel.notice) {
            VStack(spacing: 14) {
                dots

                Text("Tap for each one you notice")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var dots: some View {
        HStack(spacing: 14) {
            ForEach(0..<viewModel.currentStage.count, id: \.self) { index in
                Circle()
                    .fill(index < viewModel.noticed ? Color.darkBrown : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle().stroke(Color.darkBrown.opacity(0.35), lineWidth: 1.5)
                    }
            }
        }
    }
}

#Preview {
    GroundingView(viewModel: GroundingViewModel(skillID: "grounding"))
}
