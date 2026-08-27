//
//  OppositeActionView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct OppositeActionView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: step 3
    /// writes back through a text field. It borrows rather than owns, so the
    /// host is still the one holding the session.
    @Bindable var viewModel: OppositeActionViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: OppositeActionStep.numerals,
                currentIndex: viewModel.currentStep.rawValue,
                completed: viewModel.completedIndices,
                onTap: viewModel.revisit
            )

            ScrollView(showsIndicators: false) {
                stepContent
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .animation(.easeInOut(duration: 0.28), value: viewModel.currentStep)
        .animation(.snappy, value: viewModel.emotion)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .name:  nameStep
        case .check: checkStep
        case .act:   actStep
        }
    }

    /// Chips rather than a text field. Someone in the grip of an emotion is the
    /// last person able to name it from a blank box; recognising it in a list is
    /// a far smaller ask.
    private var nameStep: some View {
        VStack(spacing: 18) {
            heading("What are you feeling?",
                    detail: "Pick the closest one. It doesn't have to be exact.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 10)], spacing: 10) {
                ForEach(Emotion.allCases) { emotion in
                    emotionChip(emotion)
                }
            }

            if let emotion = viewModel.emotion {
                labelledNote(title: "It's telling you to", body: emotion.urge, icon: "arrow.turn.down.right")
            }

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveName,
                          action: viewModel.commitEmotion)
        }
    }

    /// The fork, and the most important screen in the practice.
    ///
    /// Opposite action is only the right tool when the emotion *doesn't* fit.
    /// Skipping this question turns a DBT skill into a habit of overriding your
    /// own signals, which is a worse place to end up than the urge was.
    private var checkStep: some View {
        VStack(spacing: 18) {
            heading("Does it fit the facts?",
                    detail: "Emotions aren't wrong. The question is whether this one matches what's actually happening.")

            if let emotion = viewModel.emotion {
                labelledNote(title: "\(emotion.title) fits when",
                             body: emotion.whenItFits + ".",
                             icon: "checkmark.seal")
            }

            HStack(spacing: 14) {
                forkButton("It fits", isPrimary: false) {
                    viewModel.answerFitsTheFacts(true)
                }
                forkButton("It doesn't", isPrimary: true) {
                    viewModel.answerFitsTheFacts(false)
                }
            }
        }
    }

    @ViewBuilder
    private var actStep: some View {
        if viewModel.fitsTheFacts == true {
            fitsBranch
        } else {
            oppositeBranch
        }
    }

    /// The emotion was justified, so there is nothing to act against.
    ///
    /// This still completes the practice. Noticing that a feeling is doing its
    /// job is a real use of the skill — and telling someone "wrong answer, go
    /// back" here would teach exactly the override this screen exists to prevent.
    private var fitsBranch: some View {
        VStack(spacing: 18) {
            heading("Then it's doing its job",
                    detail: "This one isn't a malfunction — it's information.")

            CommentBox(bulge: 6, contentPadding: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.darkBrown)

                    Text("Solve the problem instead")
                        .font(.custom("Jua-Regular", size: 20))
                        .foregroundStyle(Color.darkBrown)
                        .multilineTextAlignment(.center)

                    Text("Acting against a feeling that fits the facts just talks you out of a real signal. Problem-Solving Steps is the skill for this one.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 240)
            }

            primaryButton("Finish",
                          isEnabled: viewModel.canFinish,
                          action: viewModel.finish)
        }
    }

    private var oppositeBranch: some View {
        VStack(spacing: 18) {
            heading("Do the opposite",
                    detail: "Fully, not half-heartedly. A hedged version just rehearses the avoidance.")

            if let emotion = viewModel.emotion {
                labelledNote(title: "Opposite of \(emotion.shortUrge)",
                             body: emotion.opposite,
                             icon: "arrow.uturn.up")
            }

            writingField(
                "e.g. Message Dita and tell her what happened.",
                text: $viewModel.plan,
                limit: OppositeActionViewModel.planCharLimit,
                lines: 1...3
            )

            primaryButton("Finish",
                          isEnabled: viewModel.canFinish,
                          action: viewModel.finish)
        }
    }

    // MARK: - Pieces

    private func emotionChip(_ emotion: Emotion) -> some View {
        let isSelected = viewModel.emotion == emotion

        return Button {
            viewModel.select(emotion)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: emotion.icon)
                    .font(.system(size: 20))

                Text(emotion.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : Color.darkBrown)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            // Styling belongs on the label, not the Button: hung off the Button
            // it still draws, but the hit region stays the size of the glyphs.
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.darkBrown : .white.opacity(0.85))
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    /// The fork's two answers, weighted evenly on purpose.
    ///
    /// "It doesn't" is filled only because it is the path this practice was
    /// built for — not because it is the right answer. Both are one tap, side
    /// by side, at the same size.
    private func forkButton(
        _ title: LocalizedStringKey,
        isPrimary: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(isPrimary ? .white : Color.darkBrown)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if isPrimary {
                        Capsule().fill(Color.darkBrown)
                    } else {
                        Capsule().stroke(Color.darkBrown.opacity(0.45), lineWidth: 1.5)
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func labelledNote(title: String, body: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(body)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                // Without this a wrapping line gets truncated inside an HStack.
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background { card }
    }

    private func writingField(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        limit: Int,
        lines: ClosedRange<Int>
    ) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .lineLimit(lines)
                .padding(12)
                .background { card }

            if !text.wrappedValue.isEmpty {
                Text("\(text.wrappedValue.count)/\(limit)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func heading(_ title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(title)
                // Jua has a single weight, so no `.bold()`.
                .font(.custom("Jua-Regular", size: 24))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.darkBrown)

            Text(detail)
                .font(.system(size: 15, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
    }

    private func primaryButton(
        _ title: LocalizedStringKey,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .frame(height: 46)
                .background(Color.darkBrown)
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
    }
}

#Preview {
    OppositeActionView(viewModel: OppositeActionViewModel(skillID: "opposite_action"))
}
