//
//  BreathCircle.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  A circle that grows on the inhale and shrinks on the exhale
//

import SwiftUI

/// The breathing circle: bigger on the way in, smaller on the way out.
///
/// Like `TimerRing`, it is told its scale rather than deciding it. The pacing
/// belongs to whichever practice is driving the breath — this only has to draw,
/// which is what lets one view serve a 4-4-4-4 box and a 4-6 paced breath
/// without knowing the difference.
struct BreathCircle<Label: View>: View {

    /// Driven by the caller inside a `withAnimation` that lasts the whole phase.
    let scale: CGFloat
    var diameter: CGFloat = 170
    var ringLineWidth: CGFloat = 2.6
    @ViewBuilder let label: () -> Label

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.boxBreathingCircle.opacity(1),
                            Color.boxBreathingCircle.opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: diameter / 2
                    )
                )
                .frame(width: diameter, height: diameter)
                .blur(radius: 20)
                .scaleEffect(scale)

            // A hard edge to actually follow with your breath — the blurred glow
            // alone gives the eye nothing to track.
            Circle()
                .stroke(Color.darkBrown.opacity(0.4), lineWidth: ringLineWidth)
                .frame(width: diameter * 0.9, height: diameter * 0.9)
                .scaleEffect(scale)

            label()
        }
        .frame(width: diameter, height: diameter)
    }
}

#Preview {
    BreathCircle(scale: 1.0) {
        Text("Breathe In")
            .font(.system(size: 18, design: .rounded))
            .foregroundStyle(.brown)
    }
}
