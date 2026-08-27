//
//  IntensityScale.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//
//  A 0–10 reading, tapped rather than dragged
//

import SwiftUI

/// "How much?" as eleven tap targets.
///
/// Tapped rather than dragged on purpose: discrete values are easier to hit
/// exactly than a slider is, and every question this answers — how much do you
/// believe it, how hard are you fighting it — wants a number the user picked
/// rather than one they slid past.
///
/// `value` is optional and starts nil. Pre-selecting a middle value would
/// collect a number nobody chose, and these scales are only worth anything when
/// two of them are compared.
struct IntensityScale: View {

    let label: LocalizedStringKey
    let value: Int?
    var range: ClosedRange<Int> = 0...10
    var lowLabel: LocalizedStringKey = "Not at all"
    var highLabel: LocalizedStringKey = "Completely"
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .multilineTextAlignment(.center)
                // Without this a wrapping line gets truncated inside a VStack.
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 3) {
                ForEach(range, id: \.self) { number in
                    Button {
                        onSelect(number)
                    } label: {
                        Text("\(number)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(number == value ? .white : Color.darkBrown)
                            .frame(width: 26, height: 30)
                            // Styling belongs on the label, not the Button: hung
                            // off the Button it still draws, but the hit region
                            // stays the size of the glyph.
                            .background {
                                if number == value {
                                    Capsule().fill(Color.darkBrown)
                                } else {
                                    Capsule().stroke(Color.darkBrown.opacity(0.3), lineWidth: 1)
                                }
                            }
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .animation(.snappy, value: value)
            .sensoryFeedback(.selection, trigger: value)

            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(.system(size: 11, design: .rounded))
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    IntensityScale(label: "How much do you believe it right now?", value: 7) { _ in }
        .padding()
}
