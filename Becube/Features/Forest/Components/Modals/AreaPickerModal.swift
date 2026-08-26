//
//  AreaPickerModal.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 20/08/26.
//
//  Which area does the user want to open? Shown on first run, and again each
//  time they finish an area and earn the next pick.
//

import SwiftUI

struct AreaPickerModal: View {
    let areas: [ForestArea]
    var title: String = "Where to first?"
    var message: String = "Select an area you want to explore first."
    /// Supplied only when the pick can wait. The first-run choice passes `nil`,
    /// because there is nothing else on the map to do until it is made.
    var onDismiss: (() -> Void)? = nil
    let onSelect: (ForestArea) -> Void

    var body: some View {
        ModalCard {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.forestBrown)

                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.forestBrown)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                ForEach(areas, id: \.id) { area in
                    Button {
                        onSelect(area)
                    } label: {
                        Text(area.name)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.forestBrown)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.forestSand)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Plain text rather than AreaLockedModal's filled capsule: declining
            // is the minor action here, and a second solid button would pull the
            // eye away from the areas, which are the point of the card.
            if let onDismiss {
                Button(action: onDismiss) {
                    Text("Not now")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.forestBrown.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview("First pick") {
    ZStack {
        Image(ImageResource.Backgrounds.map).resizable().ignoresSafeArea()
        AreaPickerModal(areas: ContentRepository.areas) { _ in }
    }
}

#Preview("Next pick") {
    ZStack {
        Image(ImageResource.Backgrounds.map).resizable().ignoresSafeArea()
        AreaPickerModal(
            areas: Array(ContentRepository.areas.dropFirst()),
            title: "New area unlocked",
            message: "You've collected every plant here. Pick where to explore next.",
            onDismiss: { }
        ) { _ in }
    }
}
