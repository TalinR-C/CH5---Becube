//
//  ReframingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct ReframingView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: every
    /// step here writes back through a text field. It borrows rather than owns,
    /// so the host is still the one holding the session.
    @Bindable var viewModel: ReframingViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: ReframingStep.numerals,
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
        .animation(.snappy, value: viewModel.evidenceFor)
        .animation(.snappy, value: viewModel.evidenceAgainst)
        .animation(.snappy, value: viewModel.beliefAfter)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .thought:         thoughtStep
        case .evidenceFor:     evidenceForStep
        case .evidenceAgainst: evidenceAgainstStep
        case .balanced:        balancedStep
        }
    }

    /// The one required sentence in the practice. Everything after it is a
    /// reaction to this line, so there is nowhere to go until it exists.
    private var thoughtStep: some View {
        VStack(spacing: 18) {
            heading("Catch the thought",
                    detail: "Write it exactly as it arrived — unedited, unsoftened.")

            writingField(
                "e.g. I always mess everything up.",
                text: $viewModel.thought,
                limit: ReframingViewModel.thoughtCharLimit,
                lines: 1...3
            )

            IntensityScale(
                label: "How much do you believe it right now?",
                value: viewModel.beliefBefore,
                onSelect: viewModel.rateBefore
            )

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveThought,
                          action: viewModel.commitThought)
        }
    }

    private var evidenceForStep: some View {
        VStack(spacing: 18) {
            heading("Evidence for it",
                    detail: "Facts that genuinely support the thought. Facts, not feelings.")

            thoughtRecap

            addRow(placeholder: "Add a fact",
                   text: $viewModel.draftFor,
                   canAdd: viewModel.canAddFor,
                   action: viewModel.addFor)

            evidenceList(viewModel.evidenceFor, onRemove: viewModel.removeFor)

            primaryButton(viewModel.evidenceFor.isEmpty ? nothingComesToMind : continueLabel,
                          isEnabled: true,
                          action: viewModel.commitFor)
        }
    }

    private var evidenceAgainstStep: some View {
        VStack(spacing: 18) {
            heading("Evidence against it",
                    detail: "Anything that doesn't fit. Exceptions count.")

            thoughtRecap

            addRow(placeholder: "Add a fact",
                   text: $viewModel.draftAgainst,
                   canAdd: viewModel.canAddAgainst,
                   action: viewModel.addAgainst)

            evidenceList(viewModel.evidenceAgainst, onRemove: viewModel.removeAgainst)

            primaryButton(viewModel.evidenceAgainst.isEmpty ? nothingComesToMind : continueLabel,
                          isEnabled: true,
                          action: viewModel.commitAgainst)
        }
    }

    /// The rating reappears only once a rewrite exists. Asking "how much do you
    /// believe it now?" before anything has been rewritten is asking about
    /// nothing.
    private var balancedStep: some View {
        VStack(spacing: 18) {
            heading("Write the balanced version",
                    detail: "What both columns together actually support.")

            thoughtRecap

            writingField(
                "e.g. I made a mistake this time, not every time.",
                text: $viewModel.balanced,
                limit: ReframingViewModel.balancedCharLimit,
                lines: 2...4
            )

            if !viewModel.balanced.isEmpty {
                IntensityScale(
                    label: "And how much do you believe the original now?",
                    value: viewModel.beliefAfter,
                    onSelect: viewModel.rateAfter
                )
            }

            if let shift = viewModel.beliefShift {
                Text("Belief \(shift)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .monospacedDigit()
            }

            primaryButton("Finish",
                          isEnabled: viewModel.canFinish,
                          action: viewModel.finish)
        }
    }

    // MARK: - Pieces

    /// The thought from step 1, kept in view while they work off it. Weighing
    /// evidence against a sentence you can no longer see is how people drift.
    private var thoughtRecap: some View {
        Text(viewModel.thought)
            .font(.system(size: 15, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.darkBrown)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background { card }
    }

    private func addRow(
        placeholder: LocalizedStringKey,
        text: Binding<String>,
        canAdd: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            TextField(placeholder, text: text)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .submitLabel(.done)
                .onSubmit(action)
                .padding(12)
                .background { card }

            Button(action: action) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.darkBrown))
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .opacity(canAdd ? 1 : 0.35)
        }
    }

    private func evidenceList(
        _ items: [EvidenceItem],
        onRemove: @escaping (EvidenceItem) -> Void
    ) -> some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                HStack(spacing: 10) {
                    Text(item.text)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Color.darkBrown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        onRemove(item)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background { card }
            }
        }
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

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
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
        // Styling belongs on the label, not on the Button: hung off the Button
        // it still draws, but the hit region stays the size of the text and
        // only the glyphs respond to a tap.
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

    // Spelled out as `LocalizedStringKey` rather than inlined as a ternary:
    // `Text(flag ? "A" : "B")` resolves to the plain-`String` overload, which
    // skips the string catalog and ships English into the Indonesian build.
    private var continueLabel: LocalizedStringKey { "Continue" }
    private var nothingComesToMind: LocalizedStringKey { "Nothing comes to mind" }
}

#Preview {
    ReframingView(viewModel: ReframingViewModel(skillID: "cognitive_reframing"))
}
