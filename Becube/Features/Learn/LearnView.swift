//
//  LearnView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import Foundation
import SwiftUI

struct LearnView: View {
    var body: some View {
            VStack(alignment: .leading){
                HStack (spacing: 27){
                    Spacer()
                    // practice
                    Text(ContentRepository.skills[0].image)
                    // avg rating
                    Spacer()
                }
                
                
        }
    }
}

#Preview {
    LearnView()
}
// TODO: implement
