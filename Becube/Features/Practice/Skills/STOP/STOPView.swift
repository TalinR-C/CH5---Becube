//
//  STOPView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation
import SwiftUI

struct STOPView: View {

    /// `@Bindable` rather than the plain `let` the other practices use, because
    /// Observe's note field writes back. It borrows rather than owns, so the
    /// host is still the one holding the session.
    @Bindable var viewModel: STOPViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: STOPStep.letters,
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
        .animation(.easeInOut(duration: 0.2), value: viewModel.observePromptIndex)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .freeze:   freezeStep
        case .stepBack: stepBackStep
        case .observe:  observeStep
        case .proceed:  proceedStep
        }
    }

    /// The forced few seconds are the content here — there is nothing to do but
    /// not do anything, which is the whole instruction.
    private var freezeStep: some View {
        VStack(spacing: 18) {
            heading("Stop", detail: "Don't move.")

            TimerRing(progress: viewModel.phaseProgress) {
                Text("\(viewModel.secondsLabel)")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .contentTransition(.numericText(countsDown: true))
            }
        }
    }

    private var stepBackStep: some View {
        VStack(spacing: 18) {
            heading("Take a step back", detail: "Physically, or in your head.")

            BreathCircle(scale: viewModel.breathScale) {
                Text(breathLabel)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.brown)
            }
        }
    }

    private var observeStep: some View {
        VStack(spacing: 18) {
            heading("Observe", detail: "Nothing to fix yet — just notice.")

            Text(observePrompt)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.darkBrown)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)

            Text("\(viewModel.observePromptIndex + 1) of \(STOPViewModel.observePromptCount)")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)

            noteField

            primaryButton("Next") { viewModel.nextPrompt() }
        }
    }

    private var proceedStep: some View {
        VStack(spacing: 18) {
            heading("Proceed", detail: "Choose what actually helps — not just what feels urgent.")

            // Copy, not a link: completing the practice puts up the celebration
            // screen, and navigating away from here would race it.
            Text("Not sure? Your toolkit on the Shelf holds the skills you've kept close.")
                .font(.system(size: 14, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            primaryButton("I know what I'll do") { viewModel.commit() }
        }
    }

    // MARK: - Pieces

    /// Optional on purpose, and never a gate on moving forward — someone at the
    /// edge of an impulsive decision should not be held up by a text field.
    private var noteField: some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextField("Jot down what you notice (optional)",
                      text: $viewModel.observationNote,
                      axis: .vertical)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .lineLimit(2...4)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.85))
                )

            if !viewModel.observationNote.isEmpty {
                Text("\(viewModel.observationNote.count)/\(STOPViewModel.noteCharLimit)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func heading(_ title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.darkBrown)

            Text(detail)
                .font(.system(size: 15, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
    }

    private func primaryButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .frame(height: 46)
            .background(Color.darkBrown)
            .clipShape(Capsule())
    }

    // Spelled out as `LocalizedStringKey` rather than inlined as a ternary or a
    // subscript: `Text(flag ? "A" : "B")` resolves to the plain-`String`
    // overload, which skips the string catalog and ships English everywhere.

    private var breathLabel: LocalizedStringKey {
        viewModel.breathPhase == .inhale ? "Breathe In" : "Breathe Out"
    }

    private var observePrompt: LocalizedStringKey {
        switch viewModel.observePromptIndex {
        case 0:  "What do you notice in your body?"
        case 1:  "What emotion is here?"
        default: "What is the urge telling you to do?"
        }
    }
}

#Preview {
    ZStack {
        Color("Warm Cream").ignoresSafeArea()
        STOPView(viewModel: STOPViewModel(skillID: "stop_skill"))
            .padding(30)
    }
}
