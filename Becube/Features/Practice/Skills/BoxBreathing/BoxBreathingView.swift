//
//  BoxBreathingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

struct BoxBreathingView: View {

    /// Owned by `PracticeHostView`. A plain `let` is enough: `@Observable`
    /// means SwiftUI still re-renders when `dotPosition` or `currentPhase`
    /// change, and `@State` here would fight the host for ownership.
    let viewModel: BoxBreathingViewModel

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [
                        Color.boxBreathingCircle.opacity(1),
                        Color.boxBreathingCircle.opacity(0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 135
                ))
                .frame(width: 250, height: 250)
                .blur(radius: 20)
                .scaleEffect(viewModel.circleScale)

            Rectangle()
                .stroke(Color.darkBrown, lineWidth: 1.86)
                .frame(width: viewModel.squareSize, height: viewModel.squareSize)

            Text(viewModel.currentPhase.label)
                .font(.system(size: 22, weight: .regular, design: .rounded))
                .foregroundStyle(.brown)

            Circle()
                .fill(Color.darkBrown)
                .frame(width: 23.15, height: 23.15)
                .position(viewModel.dotPosition)
        }
        .frame(width: viewModel.squareSize, height: viewModel.squareSize)
    }
}

#Preview {
    BoxBreathingView(viewModel: BoxBreathingViewModel(skillID: "box_breathing"))
}
