//
//  UrgeSurfingView.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 26/08/26.
//

import SwiftUI

struct UrgeSurfingView: View {
    @State var viewModel: UrgeSurfingViewModel
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                switch viewModel.step {
                case .name:
                    nameStepContent
                case .observe:
                    observeStepContent
                case .surf:
                    surfStepContent
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 1: Name the Urge
    private var nameStepContent: some View {
        VStack(spacing: 24) {
            Text("Name the Urge")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.text)
                .padding(.top, 30)

            CommentBox(text: "Say what you're feeling the urge to do. Naming it gives you a little space to respond instead of react.")

            VStack(alignment: .leading, spacing: 8) {
                Text("I have an urge to...")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                TextField("check my phone, yell, use...", text: $viewModel.urgeText, axis: .vertical)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(.text)
                    .lineLimit(1...3)
                    .focused($nameFieldFocused)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.darkBrown.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.darkBrown.opacity(0.25), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 8)

            continueButton(enabled: viewModel.canContinueFromName)
        }
    }

    // MARK: - Step 2: Observe Without Judgment
    private var observeStepContent: some View {
        VStack(spacing: 24) {
            Text("Notice Without Judging")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.text)
                .padding(.top, 30)

            CommentBox(text: "Where do you feel this in your body right now? There's no wrong answer, just notice.")

            bodyLocationGrid

            continueButton(enabled: viewModel.canContinueFromObserve)
        }
    }

    private var bodyLocationGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(BodyLocation.allCases) { location in
                let isSelected = viewModel.selectedLocations.contains(location)
                Button {
                    viewModel.toggleLocation(location)
                } label: {
                    Text(location.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected ? .white : .darkBrown)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.darkBrown : Color.darkBrown.opacity(0.1))
                        )
                }
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Step 3: Breathe and Surf (press-free, looping)
    private var surfStepContent: some View {
        VStack(spacing: 24) {
            Text("Ride the Wave")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.text)
                .padding(.top, 30)

            CommentBox(text: "Picture the urge as a wave. Follow your breath as it rises and falls. Let it come, and let it go.")

            waveIllustration(highlightFraction: viewModel.breathPhase == .inhale ? 1 : 0)
                .animation(
                    .easeInOut(duration: viewModel.breathPhase == .inhale ? viewModel.inhaleDuration : viewModel.exhaleDuration),
                    value: viewModel.breathPhase
                )
                .padding(.top, 8)

            Text(viewModel.breathPhase.label)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.darkBrown)
                .id(viewModel.breathPhase.label)
                .transition(.opacity)
                .animation(.easeIn(duration: 0.3), value: viewModel.breathPhase)

            if viewModel.showReminder {
                Text("This urge isn't permanent. You've ridden out hard moments before. Tap Done below whenever you're ready.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Shared continue button
    private func continueButton(enabled: Bool) -> some View {
        Button {
            nameFieldFocused = false
            viewModel.advance()
        } label: {
            Text("Continue")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(enabled ? .white : .darkBrown.opacity(0.35))
        }
        .frame(maxWidth: 120)
        .frame(height: 56)
//        .background(Color.text)
        .background(
            Capsule()
                .fill(enabled ? Color.darkBrown : Color.darkBrown.opacity(0.1))
        )
        .disabled(!enabled)
    }

    // MARK: - Wave shape (visually unchanged from the original — now
    // driven by breath phase instead of a hold gesture)
    private func waveIllustration(highlightFraction: CGFloat) -> some View {
        ZStack {
            UrgeWaveShape()
                .stroke(Color.darkBrown, lineWidth: 2)

            UrgeWaveFillShape()
                .fill(Color.darkBrown.opacity(0.45))
                .mask(alignment: .leading) {
                    Rectangle()
                        .frame(
                            width: viewModel.curveSize.width * highlightFraction,
                            height: viewModel.curveSize.height
                        )
                }

            if highlightFraction > 0 {
                Circle()
                    .fill(Color.darkBrown)
                    .frame(width: 14, height: 14)
                    .position(markerPosition(for: highlightFraction))
            }
        }
        .frame(width: viewModel.curveSize.width, height: viewModel.curveSize.height)
    }

    /// Approximates the dot's height using a sine hump, not a true readout
    /// of the bezier's real y-value, just close enough visually to look
    /// like it's riding the wave.
    private func markerPosition(for fraction: CGFloat) -> CGPoint {
        let x = viewModel.curveSize.width * fraction
        let heightFraction = sin(fraction * .pi)
        let y = viewModel.curveSize.height * (1 - heightFraction)
        return CGPoint(x: x, y: y)
    }
}

/// The wave's outline, just the curved line. Unchanged from the original.
struct UrgeWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseline = rect.maxY
        path.move(to: CGPoint(x: rect.minX, y: baseline))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.25, y: baseline),
            control2: CGPoint(x: rect.midX - rect.width * 0.15, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: baseline),
            control1: CGPoint(x: rect.midX + rect.width * 0.15, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.25, y: baseline)
        )
        return path
    }
}

/// The same curve closed back along the baseline, a fillable shape masked
/// to show how much of it is "revealed" so far. Unchanged from the original.
struct UrgeWaveFillShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseline = rect.maxY
        path.move(to: CGPoint(x: rect.minX, y: baseline))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.25, y: baseline),
            control2: CGPoint(x: rect.midX - rect.width * 0.15, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: baseline),
            control1: CGPoint(x: rect.midX + rect.width * 0.15, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.25, y: baseline)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: baseline))
        path.closeSubpath()
        return path
    }
}

#Preview {
    let viewModel = UrgeSurfingViewModel(skillID: "urge_surfing")
    return UrgeSurfingView(viewModel: viewModel)
}
