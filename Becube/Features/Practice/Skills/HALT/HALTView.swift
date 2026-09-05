//
//  HALTView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct HALTView: View {

    /// Owned by `PracticeHostView`. A plain `let`: `@Observable` still drives
    /// re-renders, and `@State` here would fight the host for ownership.
    let viewModel: HALTViewModel

    var body: some View {
        VStack(spacing: 26) {
            LetterProgress(
                letters: HALTNeed.letters,
                currentIndex: viewModel.letterIndex,
                completed: viewModel.completedIndices,
                onTap: { index in
                    guard let need = HALTNeed(rawValue: index) else { return }
                    viewModel.select(need)
                }
            )

            switch viewModel.stage {
            case .questions: questionContent
            case .summary:   summaryContent
            }
        }
        .animation(.snappy, value: viewModel.currentNeed)
        .animation(.easeInOut(duration: 0.25), value: viewModel.stage)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.answers.count)
    }

    // MARK: - Questions

    private var questionContent: some View {
        VStack(spacing: 24) {
            CommentBox(bulge: 6, contentPadding: 20) {
                VStack(spacing: 10) {
                    Image(systemName: viewModel.currentNeed.icon)
                        .font(.system(size: 26))
                        .foregroundStyle(Color.darkBrown)

                    Text(viewModel.currentNeed.question)
                        // Jua has a single weight, so no `.bold()` — it would be
                        // synthesised rather than drawn.
                        .font(.custom("Jua-Regular", size: 22))
                        .foregroundStyle(Color.darkBrown)
                        .multilineTextAlignment(.center)

                    Text(viewModel.currentNeed.prompt)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        // Without this a wrapping line gets truncated inside a card.
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 240)
            }

            HStack(spacing: 14) {
                answerButton("No", isYes: false)
                answerButton("Yes", isYes: true)
            }
        }
    }

    /// Yes is the filled one. It is the answer that leads somewhere, and on a
    /// screen you are using because something feels off it should not be the
    /// one you have to hunt for.
    private func answerButton(_ title: LocalizedStringKey, isYes: Bool) -> some View {
        Button {
            viewModel.answer(isYes)
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(isYes ? .white : Color.darkBrown)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                // Styling belongs on the label, not the Button: hung off the
                // Button it still draws, but the hit region stays the size of
                // the text and only the glyphs respond to a tap.
                .background {
                    if isYes {
                        Capsule().fill(Color.darkBrown)
                    } else {
                        Capsule().stroke(Color.darkBrown.opacity(0.45), lineWidth: 1.5)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Summary

    @ViewBuilder
    private var summaryContent: some View {
        if let primary = viewModel.primaryNeed {
            VStack(spacing: 16) {
                CommentBox(bulge: 6, contentPadding: 20) {
                    VStack(spacing: 10) {
                        Image(systemName: primary.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(Color.darkBrown)

                        Text("Start with \(primary.title.lowercased())")
                            .font(.custom("Jua-Regular", size: 22))
                            .foregroundStyle(Color.darkBrown)
                            .multilineTextAlignment(.center)

                        Text(primary.action)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: 240)
                }

                alsoFlagged
            }
        } else {
            cleanCheckIn
        }
    }

    /// The rest of the yeses, named but not competing. One thing to do next is
    /// the point of the skill; a to-do list of four is how it stops working.
    @ViewBuilder
    private var alsoFlagged: some View {
        let others = viewModel.flaggedNeeds.dropFirst()

        if !others.isEmpty {
            VStack(spacing: 6) {
                Text("Also flagged")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(others.map(\.title).joined(separator: " · "))
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
            }
        }
    }

    /// Four noes is a result, not a blank. Saying so is what stops the screen
    /// feeling like a waste of the minute it just took.
    private var cleanCheckIn: some View {
        CommentBox(bulge: 6, contentPadding: 20) {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.darkBrown)

                Text("None of the four")
                    .font(.custom("Jua-Regular", size: 22))
                    .foregroundStyle(Color.darkBrown)

                Text("You checked, and it isn't hunger, anger, loneliness or tiredness. Knowing that is worth the minute.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 240)
        }
    }
}

#Preview {
    HALTView(viewModel: HALTViewModel(skillID: "halt_check_in"))
}
