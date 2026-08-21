//
//  Components.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 19/08/26.
//

import SwiftUI

// TailPosition and BulgingCardShape used to be declared here as well. They now live
// in Becube/Components/BulgingCardShape.swift so every feature can share one copy —
// two identical declarations in the same target is a redeclaration error in Swift.
// Nothing else changed: both types are still visible from here, since everything in
// the app target shares a single namespace regardless of which folder the file is in.

struct BulgingCard<Content: View>: View {
    var tailPosition: TailPosition = .none
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(24)
            .background(
                BulgingCardShape(cornerRadius: 40, bulge: 6, tailPosition: tailPosition)
                    .stroke(Color.brown, lineWidth: 2)
            )
            .padding(8)
            .background(
                BulgingCardShape(cornerRadius: 48, bulge: 8, tailPosition: tailPosition)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
    }
}
