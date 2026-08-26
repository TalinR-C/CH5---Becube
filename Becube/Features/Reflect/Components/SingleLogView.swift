//
//  SingleLogView.swift
//  Becube
//
//  Created by David Paul Ong on 20/08/26.
//

import SwiftUI
import SwiftData

struct SingleLogView: View {
    @State var viewModel: ReflectViewModel
    @State var log: Log
    var body: some View {
        CommentBox(cornerRadius: 16, bulge: 3, tailPosition: .none) {
            HStack{
                VStack(alignment: .leading){
                    HStack(alignment: .bottom){
                        Image("rating_\(log.rating ?? 0)")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text(viewModel.ratingName(rating: log.rating ?? 0))
                            .font(Font.system(size: 17))
                            .foregroundStyle(Color.brown).bold()
                            .padding(.bottom, 3)
                        Spacer()
                        Text(log.date, style: .time)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.darkBrown.opacity(0.35))
                            .padding(.bottom, 10)
                    }
                    Text(log.journal ?? "No journal")
                        .font(Font.system(size: 15))
                        .foregroundStyle(Color.brown)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .frame(width: 300)
        }
    }
}

