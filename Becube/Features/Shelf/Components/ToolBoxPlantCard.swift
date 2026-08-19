//
//  ToolBoxPlantCard.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 18/08/26.
//

import SwiftUI

struct ToolBoxPlantCard: View {
    let name: String
    let averageRating: Int
    let timesCompleted: Int

    var body: some View {
        ZStack {
            Image("Flower")
                .padding(.top, 48)

            VStack {
                ZStack {
                    Image("CommentBox")
                        .padding(.top, 12)
                    Text(name)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 12)
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack(spacing: 0) {
                    ZStack {
                        Image("Star")
                        Text("\(timesCompleted)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    ZStack {
                        Image("Star")
                        Text("\(averageRating)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                }
            }
        }
    }
}

#Preview {
    ToolBoxPlantCard(name: "Snake Plant", averageRating: 4, timesCompleted: 12)
        .frame(width: 150, height: 200)
        .background(Color.gray.opacity(0.2))
}
