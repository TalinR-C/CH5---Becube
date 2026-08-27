//
//  TimerRing.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  A countdown drawn as a closing ring
//

import SwiftUI

/// A phase's remaining time, drawn as a ring that closes, with whatever the
/// practice wants to say in the middle.
///
/// Takes `progress` rather than owning a timer. The ViewModel already runs the
/// clock, and two sources of truth for "how far through are we" is exactly how
/// a ring ends up disagreeing with the number printed inside it.
struct TimerRing<Label: View>: View {

    /// 1 at the start of the phase, 0 at its end.
    let progress: Double
    var diameter: CGFloat = 140
    var lineWidth: CGFloat = 8
    /// Defaulted, so every existing call site keeps the brown ring it had. A
    /// practice whose phases mean different things — PMR's tense against its
    /// release — passes its own so the colour carries that difference too.
    var tint: Color = .darkBrown
    @ViewBuilder let label: () -> Label

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                // Trim starts at three o'clock; everyone reads a countdown from twelve.
                .rotationEffect(.degrees(-90))
                // Matched to the ViewModel's tick so the ring glides between ticks
                // instead of stepping twenty times a second.
                .animation(.linear(duration: 0.05), value: progress)

            label()
        }
        .frame(width: diameter, height: diameter)
    }
}

#Preview {
    TimerRing(progress: 0.7) {
        Text("7")
            .font(.system(size: 40, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.darkBrown)
    }
}
