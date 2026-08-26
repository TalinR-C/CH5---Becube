//
//  BackButton.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 20/08/26.
//

import SwiftUI


struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            Button {
                
               dismiss()
                
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18.51, weight: .semibold))
                    .foregroundColor(Color(.systemBrown))
                    .frame(width: 46.75, height: 46.75)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.6))
                    )
                    .overlay(
                        Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    // Without this the target is the chevron glyph, not the disc:
                    // the frame around it is transparent, and a Circle() supplied
                    // as a background is decoration that hit-testing ignores.
                    // Circle rather than Rectangle so the corners outside the
                    // disc stay inert.
                    .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
