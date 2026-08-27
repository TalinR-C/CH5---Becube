//
//  AcceptanceView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct AcceptanceView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: step 1
    /// writes back through a text field. It borrows rather than owns, so the
    /// host is still the one holding the session.
    @Bindable var viewModel: AcceptanceViewModel

    /// The line the whole skill turns on, straight from the content.
    private static let phrase = "I don't have to like this.\nI just don't have to fight it right now."

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: AcceptanceStep.numerals,
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
        .animation(.snappy, value: viewModel.fightAfter)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .name:    nameStep
        case .measure: measureStep
        case .accept:  acceptStep
        case .notice:  noticeStep
        }
    }

    private var nameStep: some View {
        VStack(spacing: 18) {
            heading("What can't you change?",
                    detail: "Something that's already true, however much you'd rather it weren't.")

            writingField(
                "e.g. She isn't coming back.",
                text: $viewModel.reality,
                limit: AcceptanceViewModel.realityCharLimit,
                lines: 1...3
            )

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveName,
                          action: viewModel.commitReality)
        }
    }

    private var measureStep: some View {
        VStack(spacing: 18) {
            heading("How hard are you fighting it?",
                    detail: "Not how bad it is — how much of you is arguing that it shouldn't be true.")

            realityRecap

            IntensityScale(
                label: "Right now",
                value: viewModel.fightBefore,
                highLabel: "With everything",
                onSelect: viewModel.rateBefore
            )

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveMeasure,
                          action: viewModel.commitMeasure)
        }
    }

    /// The one step with no text field and nothing to decide.
    ///
    /// A tap would be over before it registered as anything. Holding is a beat
    /// you have to actually give — which is the difference between reading the
    /// line and saying it.
    private var acceptStep: some View {
        VStack(spacing: 22) {
            heading("Say it to yourself", detail: "Out loud, if you can.")

            realityRecap

            Text(Self.phrase)
                .font(.custom("Jua-Regular", size: 19))
                .foregroundStyle(Color.darkBrown)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 8)

            HoldToAffirm(
                title: "Hold to accept",
                duration: AcceptanceViewModel.holdDuration,
                action: viewModel.affirm
            )

            Text("Breathe out while you hold.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private var noticeStep: some View {
        VStack(spacing: 18) {
            heading("Look again", detail: "The situation is the same. Check whether the fighting is.")

            realityRecap

            IntensityScale(
                label: "How hard are you fighting it now?",
                value: viewModel.fightAfter,
                highLabel: "With everything",
                onSelect: viewModel.rateAfter
            )

            if let outcome = viewModel.outcome {
                outcomeNote(outcome)
            }

            primaryButton("Finish",
                          isEnabled: viewModel.canFinish,
                          action: viewModel.finish)
        }
    }

    /// Three endings, none of them a verdict.
    ///
    /// A number that doesn't move is the ordinary result here — this practice
    /// changes nothing outside the person, and it never claimed to. Anything
    /// that reads as "you didn't accept hard enough" teaches the opposite of
    /// the skill.
    @ViewBuilder
    private func outcomeNote(_ outcome: AcceptanceOutcome) -> some View {
        VStack(spacing: 6) {
            if let shift = viewModel.fightShift {
                Text("Fighting \(shift)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .monospacedDigit()
            }

            Text(outcomeMessage(outcome))
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background { card }
    }

    // Spelled out as `LocalizedStringKey` rather than inlined as a ternary:
    // `Text(flag ? "A" : "B")` resolves to the plain-`String` overload, which
    // skips the string catalog and ships English into the Indonesian build.
    private func outcomeMessage(_ outcome: AcceptanceOutcome) -> LocalizedStringKey {
        switch outcome {
        case .eased:
            return "Nothing outside you changed. The struggling did."
        case .unchanged:
            return "Still the same, and that's normal. Acceptance isn't a switch — it's something you come back to."
        case .harder:
            return "It got heavier to sit with. That happens, and noticing it is still the practice."
        }
    }

    // MARK: - Pieces

    /// The sentence from step 1, kept in view. This is the thing being accepted;
    /// losing sight of it turns the rest into an abstract exercise.
    private var realityRecap: some View {
        Text(viewModel.reality)
            .font(.system(size: 15, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.darkBrown)
            .frame(maxWidth: .infinity)
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

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
    }
}

/// A capsule that fills while you hold it, and only counts once it is full.
///
/// Private to this screen: it exists because saying the acceptance line needs a
/// beat of commitment that a tap can't carry. If a second practice ever wants
/// one, that's the moment it moves to `Shared/`.
///
/// No timer of its own — `onLongPressGesture` already reports both the press
/// state and the completion, so the fill is one animation and the commitment is
/// one callback.
private struct HoldToAffirm: View {

    let title: LocalizedStringKey
    let duration: Double
    let action: () -> Void

    @State private var fill: CGFloat = 0

    /// Counts completed holds, purely so the haptic has something honest to
    /// fire on. `fill` is no use for that: `withAnimation` sets the stored
    /// value to 1 the instant the press begins and only *renders* it over the
    /// duration, so a trigger watching it would buzz at press-start.
    @State private var holdsCompleted = 0

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background {
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.darkBrown.opacity(0.35))

                    GeometryReader { geometry in
                        Capsule()
                            .fill(Color.darkBrown)
                            .frame(width: geometry.size.width * fill)
                    }
                }
                .clipShape(Capsule())
            }
            .contentShape(Capsule())
            .onLongPressGesture(minimumDuration: duration) {
                holdsCompleted += 1
                action()
            } onPressingChanged: { isPressing in
                // Filling takes the whole hold; letting go snaps back quickly,
                // so an accidental brush doesn't leave a half-full bar behind.
                withAnimation(.linear(duration: isPressing ? duration : 0.2)) {
                    fill = isPressing ? 1 : 0
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: holdsCompleted)
    }
}

#Preview {
    AcceptanceView(viewModel: AcceptanceViewModel(skillID: "radical_acceptance"))
}
