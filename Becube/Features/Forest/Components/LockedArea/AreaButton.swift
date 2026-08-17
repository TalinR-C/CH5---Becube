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
            ThinCapsule(text: areaStatus.name)
        } else {
            Lock()
        }
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        AreaButton(areaStatus: ("Area 1", true))
    }
}
