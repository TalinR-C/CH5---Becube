//
//  PMRView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct PMRView: View {

    /// Owned by `PracticeHostView`. A plain `let`: `@Observable` still drives
    /// re-renders, and `@State` here would fight the host for ownership.
    let viewModel: PMRViewModel

    /// The same words every time. The contrast is the skill, not the phrasing —
    /// varying it per group would make the release feel like a new instruction
    /// rather than the same one landing again.
    private static let releasePrompt = "Let go all at once. Notice the difference."

    var body: some View {
        VStack(spacing: 24) {
            markers

            switch viewModel.stage {
            case .muscles:   muscleContent
            case .breathing: breathingContent
            }
        }
        .animation(.snappy, value: viewModel.currentGroup)
        .animation(.easeInOut(duration: 0.25), value: viewModel.phase)
        // Every boundary flips the phase — tense to release, and release to the
        // next group's tense — so one trigger covers the whole practice.
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.phase)
    }

    // MARK: - Muscles

    private var muscleContent: some View {
        VStack(spacing: 20) {
            groupCard
            ring
            skipButton
            caution
        }
    }

    private var groupCard: some View {
        CommentBox(bulge: 6, contentPadding: 20) {
            VStack(spacing: 8) {
                Text(viewModel.currentGroup.title)
                    // Jua has a single weight, so no `.bold()` — it would be
                    // synthesised rather than drawn.
                    .font(.custom("Jua-Regular", size: 22))
                    .foregroundStyle(Color.darkBrown)

                Text(viewModel.phase == .tense
                     ? viewModel.currentGroup.instruction
                     : Self.releasePrompt)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    // Without this a wrapping line gets truncated inside a card.
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 240)
        }
    }

    /// Tense draws at full strength, release at less than half. The colour is
    /// carrying the same contrast the muscle is.
    private var ringTint: Color {
        viewModel.phase == .tense ? Color.darkBrown : Color.darkBrown.opacity(0.45)
    }

    private var ring: some View {
        TimerRing(progress: viewModel.phaseProgress, tint: ringTint) {
            VStack(spacing: 0) {
                Text(viewModel.phase == .tense ? "TENSE" : "RELEASE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(ringTint)

                Text("\(viewModel.secondsLabel)")
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .monospacedDigit()
            }
        }
    }

    /// Only offered on the tense — skipping a release would mean skipping the
    /// part that does the work.
    @ViewBuilder
    private var skipButton: some View {
        if viewModel.phase == .tense {
            Button("Skip this one", action: viewModel.skip)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .buttonStyle(.plain)
        }
    }

    /// Stays on screen for the whole practice rather than appearing once at the
    /// start. The group it matters for might be the seventh one.
    private var caution: some View {
        Text("Skip any muscle that's injured or hurting.")
            .font(.system(size: 13, design: .rounded))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Closing breaths

    private var breathingContent: some View {
        VStack(spacing: 18) {
            BreathCircle(scale: viewModel.breathScale) {
                Text(viewModel.breathPhase == .inhale ? "Breathe In" : "Breathe Out")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.brown)
            }

            Text("Three slow breaths to finish.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Progress

    /// The trail the practice leaves behind it: one marker per group, filled
    /// once released. A skipped group stays outlined.
    private var markers: some View {
        HStack(spacing: 2) {
            ForEach(MuscleGroup.allCases) { group in
                Button {
                    viewModel.select(group)
                } label: {
                    marker(for: viewModel.state(of: group))
                        // A 10pt dot is not a tap target. The frame is what the
                        // finger gets; the dot is only what the eye gets.
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(group.title))
            }
        }
    }

    @ViewBuilder
    private func marker(for state: StepState) -> some View {
        switch state {
        case .done:
            Circle()
                .fill(Color.darkBrown)
                .frame(width: 10, height: 10)

        case .active:
            Circle()
                .fill(Color.darkBrown)
                .frame(width: 10, height: 10)
                .padding(5)
                .overlay {
                    Circle().stroke(Color.darkBrown.opacity(0.35), lineWidth: 1.5)
                }

        case .upcoming:
            // Outlined rather than faded: a group you haven't reached is still
            // part of the practice, and dimming it just makes it harder to see.
            Circle()
                .stroke(Color.darkBrown.opacity(0.35), lineWidth: 1.5)
                .frame(width: 10, height: 10)
        }
    }
}

#Preview {
    PMRView(viewModel: PMRViewModel(skillID: "progressive_muscle_relaxation"))
}
