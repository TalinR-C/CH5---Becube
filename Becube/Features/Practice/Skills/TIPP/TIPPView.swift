//
//  TIPPView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation
import SwiftUI

struct TIPPView: View {

    /// Owned by `PracticeHostView`. A plain `let`: `@Observable` still drives
    /// re-renders, and `@State` here would fight the host for ownership.
    let viewModel: TIPPViewModel

    private static let settlePromptID = "settlePrompt"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(TIPPStep.allCases) { step in
                        StepRow(
                            number: step.number,
                            title: step.title,
                            detail: step.detail,
                            state: viewModel.state(of: step),
                            onTap: { viewModel.select(step) },
                            expanded: { content(for: step) }
                        )
                        .id(step)
                    }

                    if viewModel.isAskingIfSettled {
                        settlePrompt
                            .id(Self.settlePromptID)
                    }
                }
                .padding(.vertical, 4)
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.openStep)
            .animation(.snappy, value: viewModel.completed)
            .animation(.easeInOut(duration: 0.25), value: viewModel.isAskingIfSettled)
            // Whatever the practice moves to next should come to the user, not
            // the other way round — a step that opens below the fold reads as
            // nothing having happened.
            .onChange(of: viewModel.openStep) { _, step in
                guard let step else { return }
                withAnimation { proxy.scrollTo(step, anchor: .center) }
            }
            .onChange(of: viewModel.isAskingIfSettled) { _, isAsking in
                guard isAsking else { return }
                withAnimation { proxy.scrollTo(Self.settlePromptID, anchor: .bottom) }
            }
        }
    }

    // MARK: - Per-step content

    @ViewBuilder
    private func content(for step: TIPPStep) -> some View {
        switch step {
        case .cold:     coldContent
        case .exercise: exerciseContent
        case .breath:   breathContent
        case .muscle:   muscleContent
        }
    }

    /// The big circle from the sketch. No clock — the phone cannot tell whether
    /// you are holding an ice cube, so you tell it.
    private var coldContent: some View {
        Button(action: viewModel.markColdDone) {
            Circle()
                .stroke(Color.darkBrown, lineWidth: 2)
                .frame(width: 120, height: 120)
                .overlay {
                    Text("Tap when\nyou've done it")
                        .font(.system(size: 14, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.brown)
                }
                // A stroked Circle only takes taps on the stroke itself —
                // without this the middle of the target is a hole.
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var exerciseContent: some View {
        VStack(spacing: 14) {
            TimerRing(progress: viewModel.phaseProgress) {
                secondsLabel(size: 40)
            }
            startButton
        }
    }

    private var breathContent: some View {
        VStack(spacing: 14) {
            BreathCircle(scale: viewModel.breathScale) {
                VStack(spacing: 4) {
                    Text(breathLabel)
                        .font(.system(size: 18, design: .rounded))
                        .foregroundStyle(.brown)

                    Text("\(viewModel.breathCycle + 1) of \(TIPPViewModel.breathCycles)")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            startButton
        }
    }

    private var muscleContent: some View {
        VStack(spacing: 14) {
            TimerRing(progress: viewModel.phaseProgress) {
                VStack(spacing: 0) {
                    Text(muscleLabel)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.brown)
                    secondsLabel(size: 34)
                }
            }

            Text(muscleDetail)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)

            startButton
        }
    }

    // MARK: - Pieces

    // Spelled out as `LocalizedStringKey` rather than inlined as a ternary:
    // `Text(flag ? "A" : "B")` resolves to the plain-`String` overload, which
    // skips the string catalog and ships English into the Indonesian build.

    private var breathLabel: LocalizedStringKey {
        viewModel.breathPhase == .inhale ? "Breathe In" : "Breathe Out"
    }

    private var muscleLabel: LocalizedStringKey {
        viewModel.isTensing ? "Tense" : "Release"
    }

    private var muscleDetail: LocalizedStringKey {
        viewModel.isTensing ? "Make a fist and squeeze hard." : "Let it go completely."
    }

    private func secondsLabel(size: CGFloat) -> some View {
        Text("\(viewModel.secondsLabel)")
            .font(.system(size: size, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.darkBrown)
            .contentTransition(.numericText(countsDown: true))
    }

    /// Only while the clock is stopped: you need a moment to stand up before
    /// ten seconds of jumping jacks starts counting.
    @ViewBuilder
    private var startButton: some View {
        if !viewModel.isRunning {
            // Styling belongs on the label, not on the Button: hung off the
            // Button it still draws, but the hit region stays the size of the
            // text and only the glyphs respond to a tap.
            Button { viewModel.begin() } label: {
                Text("Start")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 42)
                    .background(Color.darkBrown)
                    .clipShape(Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    /// TIPP's real instruction: one technique may be enough, and if it is not,
    /// you stack another. Asking is cheaper than guessing wrong in either
    /// direction — and it is the one question someone in crisis can answer.
    private var settlePrompt: some View {
        VStack(spacing: 14) {
            Text("Feeling steadier?")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)

            HStack(spacing: 10) {
                if viewModel.hasUntriedSteps {
                    Button("Not yet") { viewModel.continueWithAnother() }
                        .buttonStyle(SettleButtonStyle(isFilled: false))
                }

                Button("I'm steadier") { viewModel.settle() }
                    .buttonStyle(SettleButtonStyle(isFilled: true))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.85))
        )
    }
}

/// Shared by both answers so they read as one question, not two unrelated
/// buttons.
private struct SettleButtonStyle: ButtonStyle {
    let isFilled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isFilled ? .white : Color.darkBrown)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background {
                Capsule()
                    .fill(isFilled ? Color.darkBrown : .white)
                    .overlay {
                        Capsule().stroke(Color.darkBrown.opacity(isFilled ? 0 : 0.4), lineWidth: 1)
                    }
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Display text
//
// Kept in the view layer, not the ViewModel: `Text(LocalizedStringKey)` picks
// these up from the string catalog on its own, which it cannot do for a `String`
// the ViewModel has already resolved.

private extension TIPPStep {
    var title: LocalizedStringKey {
        switch self {
        case .cold:     "Cold"
        case .exercise: "Exercise"
        case .breath:   "Breath"
        case .muscle:   "Muscle"
        }
    }

    var detail: LocalizedStringKey {
        switch self {
        case .cold:     "Hold something cold, or splash cold water on your face."
        case .exercise: "A short burst — jumping jacks, or sprint in place."
        case .breath:   "Breathe out for longer than you breathe in."
        case .muscle:   "Tense one muscle group hard, then let it go."
        }
    }
}

#Preview {
    ZStack {
        Color("Warm Cream").ignoresSafeArea()
        TIPPView(viewModel: TIPPViewModel(skillID: "tipp_skill"))
            .padding(30)
    }
}
