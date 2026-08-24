//
//  AreaPickerModal.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 20/08/26.
//
//  First-run prompt: which area does the user want to start in?
//

import SwiftUI

struct AreaPickerModal: View {
    let areas: [ForestArea]
    let onSelect: (ForestArea) -> Void

    var body: some View {
        ModalCard {
            VStack(spacing: 4) {
                Text("Where to first?")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.forestBrown)

                Text("Select an area you want to explore first.")
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
        }
    }
}

#Preview {
    ZStack {
        Image(ImageResource.Backgrounds.map).resizable().ignoresSafeArea()
        AreaPickerModal(areas: ContentRepository.areas) { _ in }
    }
}
