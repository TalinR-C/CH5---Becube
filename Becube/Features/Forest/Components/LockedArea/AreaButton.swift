//
//  AreaButton.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

struct AreaButton: View {
    var areaStatus: (name: String, unlocked: Bool)

    var body: some View {
        if areaStatus.unlocked {
            // Same recipe as ToolBoxPlantCard's name bubble (14/2, contentPadding 6),
            // minus the tail — a map label points at nothing, it just sits on its slot.
            CommentBox(cornerRadius: 14, bulge: 2, tailPosition: .none, contentPadding: 6) {
                Text(areaStatus.name)
                    .font(.custom("Jua-Regular", size: 18))
                    .foregroundStyle(Color.forestBrown)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 16)
            }
        } else {
            Lock()
        }
    }
}

#Preview {
    ZStack {
        Image(ImageResource.Backgrounds.map)
            .resizable()
            .ignoresSafeArea()

        VStack(spacing: 24) {
            AreaButton(areaStatus: ("Waterfall", true))
            AreaButton(areaStatus: ("Pond", true))
            AreaButton(areaStatus: ("Field", false))
        }
    }
}
