//
//  AreaLockedModal.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 20/08/26.
//
//  Shown when the user taps an area they have not unlocked yet.
//

import SwiftUI

struct AreaLockedModal: View {
    let onClose: () -> Void

    var body: some View {
        ModalCard {
            Lock()
                .padding(.bottom, 4)

            VStack(spacing: 6) {
                Text("Area Locked")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.forestBrown)

                Text("Complete exploring previous area to unlock a new area")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.forestBrown)
                    .multilineTextAlignment(.center)
            }

            Button(action: onClose) {
                Text("Close")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.forestBrown))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
    }
}

#Preview {
    ZStack {
        Image(ImageResource.forestMap).resizable().ignoresSafeArea()
        AreaLockedModal { }
    }
}
