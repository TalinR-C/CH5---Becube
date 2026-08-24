//
//  ModalCard.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 20/08/26.
//
//  Shared chrome for the forest map's modals: a dimmed backdrop with a
//  double-bordered card floating over it.
//

import SwiftUI

extension Color {
    /// The forest palette, shared by the map's modals.
    static let forestBrown = Color(red: 158 / 255, green: 110 / 255, blue: 74 / 255)
    static let forestCream = Color(red: 255 / 255, green: 253 / 255, blue: 248 / 255)
    /// Fill for tappable rows inside a card — a shade darker than the card itself.
    static let forestSand = Color(red: 250 / 255, green: 244 / 255, blue: 231 / 255)
}

/// A centred card over a washed-out backdrop.
///
/// The backdrop swallows taps so the map underneath stays inert while a modal
/// is up. Dismissal is deliberately left to the caller's own controls — both
/// modals ask for a decision, so tapping away is not an answer.
struct ModalCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.white
                .opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { }

            VStack(spacing: 16) {
                content
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(
                BulgingCardShape(cornerRadius: 32, bulge: 4)
                    .stroke(Color.forestBrown, lineWidth: 2)
            )
            .padding(8)
            .background(
                BulgingCardShape(cornerRadius: 40, bulge: 6)
                    .fill(Color.forestCream)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}

#Preview {
    ZStack {
        Image(ImageResource.Backgrounds.map).resizable().ignoresSafeArea()
        ModalCard {
            Text("Title")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(Color.forestBrown)
            Text("Some supporting copy that explains the choice.")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.forestBrown)
                .multilineTextAlignment(.center)
        }
    }
}
