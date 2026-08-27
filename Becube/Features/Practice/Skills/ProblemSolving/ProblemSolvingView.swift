//
//  ProblemSolvingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation
import SwiftUI

struct ProblemSolvingView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: every
    /// step here writes back through a text field. It borrows rather than owns,
    /// so the host is still the one holding the session.
    @Bindable var viewModel: ProblemSolvingViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: ProblemSolvingStep.numerals,
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
        .animation(.easeInOut(duration: 0.2), value: viewModel.weighIndex)
        .animation(.snappy, value: viewModel.options)
        .animation(.snappy, value: viewModel.chosenOptionID)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .define: defineStep
        case .list:   listStep
        case .weigh:  weighStep
        case .pick:   pickStep
        case .tryIt:  tryItStep
        }
    }

    /// The one required field in the whole practice. Everything after it is a
    /// reaction to this sentence, so there is nowhere to go until it exists.
    private var defineStep: some View {
        VStack(spacing: 18) {
            heading("Define the problem", detail: "One clear sentence. The problem, not the fix.")

            writingField(
                "e.g. I keep missing my morning meds.",
                text: $viewModel.problem,
                limit: ProblemSolvingViewModel.problemCharLimit,
                lines: 2...4
            )

            primaryButton("Next", isEnabled: viewModel.canLeaveDefine) {
                viewModel.commitProblem()
            }
        }
    }

    private var listStep: some View {
        VStack(spacing: 18) {
            heading("List your options", detail: "Every idea counts — the bad ones especially. You are not choosing yet.")

            problemRecap

            if !viewModel.isOptionListFull {
                addOptionRow
            }

            VStack(spacing: 8) {
                ForEach(viewModel.options) { option in
                    optionRow(option)
                }
            }

            Text(listFootnote)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)

            primaryButton("Next", isEnabled: viewModel.canLeaveList) {
                viewModel.commitOptions()
            }
        }
    }

    /// One option at a time. Four options weighed on a single screen is eight
    /// text fields at once, which is a form — and nobody fills in a form while
    /// they are stuck.
    private var weighStep: some View {
        VStack(spacing: 18) {
            heading("Weigh each one", detail: "One good thing, one bad thing. Both optional.")

            Text("Option \(viewModel.weighIndex + 1) of \(viewModel.options.count)")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)

            Text(viewModel.currentOption?.text ?? "")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.darkBrown)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background { card }

            labelledField("One upside", placeholder: "What is good about it?", text: $viewModel.currentUpside)
            labelledField("One downside", placeholder: "What is the cost?", text: $viewModel.currentDownside)

            HStack(spacing: 10) {
                if viewModel.weighIndex > 0 {
                    secondaryButton("Back") { viewModel.previousOption() }
                }

                primaryButton(weighAdvanceTitle, isEnabled: true) {
                    viewModel.nextOption()
                }
            }
        }
    }

    private var pickStep: some View {
        VStack(spacing: 18) {
            heading("Pick one to try", detail: "Not the perfect one — the one you can actually do.")

            VStack(spacing: 10) {
                ForEach(viewModel.options) { option in
                    choiceRow(option)
                }
            }

            primaryButton("I'll try this", isEnabled: viewModel.chosenOptionID != nil) {
                viewModel.commitChoice()
            }
        }
    }

    /// The honest step. Checking how it went cannot happen in this sitting, so
    /// the screen says so and hands them to the place where it can — the log
    /// they write after they have actually tried it.
    private var tryItStep: some View {
        VStack(spacing: 18) {
            heading("Check how it went", detail: "This part happens later.")

            VStack(spacing: 6) {
                Text("You're trying")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)

                Text(viewModel.chosenOption?.text ?? "")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.darkBrown)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background { card }

            Text("Once you've tried it, come back and log how it went. That's the fifth step — and it's what tells you whether to keep going or pick another option.")
                .font(.system(size: 14, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            primaryButton("I'll try it", isEnabled: true) {
                viewModel.finish()
            }
        }
    }

    // MARK: - Pieces

    /// The sentence from step 1, kept in view while they work off it. Weighing
    /// options against a problem you can no longer see is how people drift.
    private var problemRecap: some View {
        Text(viewModel.problem)
            .font(.system(size: 15, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.darkBrown)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background { card }
    }

    private var addOptionRow: some View {
        HStack(spacing: 10) {
            TextField("Add an idea", text: $viewModel.draftOption)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .submitLabel(.done)
                .onSubmit { viewModel.addOption() }
                .padding(12)
                .background { card }

            Button {
                viewModel.addOption()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.darkBrown))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canAddOption)
            .opacity(viewModel.canAddOption ? 1 : 0.35)
        }
    }

    private func optionRow(_ option: SolutionOption) -> some View {
        HStack(spacing: 10) {
            Text(option.text)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                viewModel.removeOption(option)
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

    /// Shows whatever was written on step 3 underneath the idea, so the choice
    /// is made from the weighing rather than from memory of it.
    private func choiceRow(_ option: SolutionOption) -> some View {
        let isChosen = viewModel.chosenOptionID == option.id

        return Button {
            viewModel.choose(option)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isChosen ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isChosen ? Color.darkBrown : Color.darkBrown.opacity(0.35))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.text)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.darkBrown)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    if !option.upside.isEmpty {
                        weighNote(symbol: "plus", text: option.upside)
                    }
                    if !option.downside.isEmpty {
                        weighNote(symbol: "minus", text: option.downside)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(isChosen ? 0.9 : 0.5))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.darkBrown.opacity(isChosen ? 0.6 : 0), lineWidth: 1.5)
                    }
            )
        }
        .buttonStyle(.plain)
    }

    private func weighNote(symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.top, 3)

            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func labelledField(
        _ label: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)

            writingField(
                placeholder,
                text: text,
                limit: ProblemSolvingViewModel.weighNoteCharLimit,
                lines: 1...3
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            // Styling belongs on the label, not on the Button: hung off the
            // Button it still draws, but the hit region stays the size of the
            // text and only the glyphs respond to a tap.
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

    private func secondaryButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
            // Styling belongs on the label, not on the Button: hung off the
            // Button it still draws, but the hit region stays the size of the
            // text and only the glyphs respond to a tap.
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .padding(.horizontal, 24)
                .frame(height: 46)
                .background {
                    Capsule()
                        .fill(.white)
                        .overlay { Capsule().stroke(Color.darkBrown.opacity(0.4), lineWidth: 1) }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
    }

    // Spelled out as `LocalizedStringKey` rather than inlined as a ternary:
    // `Text(flag ? "A" : "B")` resolves to the plain-`String` overload, which
    // skips the string catalog and ships English into the Indonesian build.

    private var weighAdvanceTitle: LocalizedStringKey {
        viewModel.isLastOption ? "Pick one" : "Next"
    }

    private var listFootnote: LocalizedStringKey {
        if viewModel.isOptionListFull {
            "That's plenty to choose from."
        } else if viewModel.canLeaveList {
            "Add more if you have them — a silly one often loosens a better one."
        } else {
            "Add at least two. The first idea is rarely the only one."
        }
    }
}

#Preview {
    ZStack {
        Color("Warm Cream").ignoresSafeArea()
        ProblemSolvingView(viewModel: ProblemSolvingViewModel(skillID: "problem_solving_steps"))
            .padding(30)
    }
}
