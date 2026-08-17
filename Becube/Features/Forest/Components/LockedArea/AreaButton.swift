//
//  AreaButton.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

struct AreaButton: View {
    var areaStatus: (name: String, isLocked: Bool)
    
    var body: some View {
        if areaStatus.isLocked {
            Lock()
        } else {
            ThinCapsule(text: areaStatus.name)
        }
    }
}

#Preview {
    ZStack {
        Color(.green)
        
        AreaButton(areaStatus: ("Area 1", false))
    }
}
