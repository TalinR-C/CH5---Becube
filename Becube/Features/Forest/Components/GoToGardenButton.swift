//
//  GoToGardenButton.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 14/08/26.
//

import SwiftUI

struct GoToGardenButton: View {
    var body: some View {
        VStack(spacing: 0) {
            AreaButton(areaStatus: ("Go to garden", true))
        }
    }
}

#Preview {
    ZStack {
        Color(.green)
        GoToGardenButton()
    }
}
