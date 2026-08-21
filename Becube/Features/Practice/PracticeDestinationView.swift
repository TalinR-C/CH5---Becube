//
//  PracticeDestinationView.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 20/08/26.
//

import SwiftUI

struct PracticeDestinationView: View {
    let skillID: String

    
    var body: some View {
        if let kind = PracticeKind(skillID: skillID) {
            PracticeRegistry.view(for: kind, skillID: skillID)
        } else {
            comingSoon
        }
    }

    private var comingSoon: some View {
        VStack(spacing: 12) {
            Text("Coming Soon")
                .font(.title2.bold())
            Text("This skill's practice experience isn't built yet.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
