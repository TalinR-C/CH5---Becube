//
//  StepPager.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Progress through an acronym skill, one letter per step
//

import SwiftUI

/// The letters of an acronym skill, drawn as the progress bar for walking it.
///
/// A skill like STOP is its own progress indicator: the letters are what the
/// user is trying to remember, so showing them across the top teaches the skill
/// while tracking the walk through it. Generic over the acronym so HALT, TIPP
/// and anything else spelled out of its own steps get the same treatment.
///
/// Completed letters are tappable — for a sequential skill the strip *is* the
/// back navigation, which saves putting a second control on a screen whose
/// whole job is to feel calm.
struct LetterProgress: View {

    let letters: [String]
    let currentIndex: Int
    let completed: Set<Int>
    let onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                Button {
                    onTap(index)
                } label: {
                    Text(letter)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(foreground(at: index))
                        .frame(width: 46, height: 46)
                        .background { background(at: index) }
                }
                .buttonStyle(.plain)
                // Only a letter you have already been to can be returned to;
                // tapping ahead would skip the step that hasn't happened yet.
                .disabled(!completed.contains(index) && index != currentIndex)
            }
        }
        .animation(.snappy, value: currentIndex)
        .animation(.snappy, value: completed)
    }

    @ViewBuilder
    private func background(at index: Int) -> some View {
        if index == currentIndex {
            Circle().fill(Color.darkBrown)
        } else if completed.contains(index) {
            Circle().fill(Color.darkBrown.opacity(0.18))
        } else {
            // Outlined rather than faded: a step you haven't reached is still
            // part of the skill, and dimming it just makes it harder to read.
            Circle().stroke(Color.darkBrown.opacity(0.45), lineWidth: 1.5)
        }
    }

    private func foreground(at index: Int) -> Color {
        index == currentIndex ? .white : Color.darkBrown
    }
}

#Preview {
    LetterProgress(
        letters: ["S", "T", "O", "P"],
        currentIndex: 2,
        completed: [0, 1],
        onTap: { _ in }
    )
}
