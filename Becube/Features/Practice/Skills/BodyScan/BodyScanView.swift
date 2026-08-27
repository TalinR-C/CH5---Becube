//
//  BodyScanView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI

struct BodyScanView: View {

    /// Owned by `PracticeHostView`. A plain `let`: `@Observable` still drives
    /// re-renders, and `@State` here would fight the host for ownership.
    let viewModel: BodyScanViewModel

    var body: some View {
        VStack(spacing: 30) {
            markers
            regionCard
            timer
        }
        .animation(.snappy, value: viewModel.currentRegion)
        // Arriving at a new region is the one moment worth feeling. Light,
        // because a body scan is the last place for a sharp tap.
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.currentRegion)
    }

    // MARK: - Pieces

    /// The trail the scan leaves behind it: one marker per region, filled once
    /// passed. Small on purpose — this is orientation, not a scoreboard.
    private var markers: some View {
        HStack(spacing: 2) {
            ForEach(BodyRegion.allCases) { region in
                Button {
                    viewModel.select(region)
                } label: {
                    marker(for: viewModel.state(of: region))
                        // A 10pt dot is not a tap target. The frame is what the
                        // finger gets; the dot is only what the eye gets.
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(region.title))
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
            // Outlined rather than faded: a region you haven't reached is still
            // part of the scan, and dimming it just makes it harder to see.
            Circle()
                .stroke(Color.darkBrown.opacity(0.35), lineWidth: 1.5)
                .frame(width: 10, height: 10)
        }
    }

    private var regionCard: some View {
        CommentBox(bulge: 6, contentPadding: 20) {
            VStack(spacing: 8) {
                Text(viewModel.currentRegion.title)
                    // Jua has a single weight, so no `.bold()` — it would be
                    // synthesised rather than drawn.
                    .font(.custom("Jua-Regular", size: 22))
                    .foregroundStyle(Color.darkBrown)

                Text(viewModel.currentRegion.prompt)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    // Without this a wrapping line gets truncated inside a card.
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 240)
        }
    }

    private var timer: some View {
        TimerRing(progress: viewModel.phaseProgress) {
            Text("\(viewModel.secondsLabel)")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .monospacedDigit()
        }
    }
}

#Preview {
    BodyScanView(viewModel: BodyScanViewModel(skillID: "body_scan"))
}
