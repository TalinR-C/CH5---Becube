//
//  PracticeRegistry.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  PracticeKind → View
//

import Foundation
import SwiftUI

struct PracticeRegistry {
    @ViewBuilder
    static func view(for kind: PracticeKind, skillID: String) -> some View {
        switch kind {
        case .boxBreathing:
            BoxBreathingView(viewModel: BoxBreathingViewModel(skillID: skillID))
        }
    }
}
