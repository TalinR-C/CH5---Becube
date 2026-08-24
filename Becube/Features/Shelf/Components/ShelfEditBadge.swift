//
//  ShelfEditBadge.swift
//  Becube
//
//  The small circular button that appears on every plant while the Shelf is in edit
//  mode: a `−` on a card standing on the toolbox plank, a `+` on one down in the
//  "Plants Collected" grid that could be promoted up there.
//

import SwiftUI

struct ShelfEditBadge: View {
    enum Role {
        case add, remove

        var symbol: String {
            switch self {
            case .add: "plus"
            case .remove: "minus"
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .add: "Add to shelf"
            case .remove: "Remove from shelf"
            }
        }
    }

    let role: Role
    /// `false` greys the badge out — used for `+` once the plank is full.
    var isEnabled: Bool = true
    let action: () -> Void

    /// Diameter of the drawn circle. The tap target is padded out past this to the 44pt
    /// Apple asks for, so the badge stays small without being fiddly to hit.
    private let diameter: CGFloat = 28

    var body: some View {
        Button(action: action) {
            Image(systemName: role.symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(ShelfPalette.darkBrown.opacity(isEnabled ? 1 : 0.3))
                .frame(width: diameter, height: diameter)
                .background(Color.white, in: Circle())
                .overlay {
                    Circle().stroke(
                        ShelfPalette.paperBorder.opacity(isEnabled ? 0.35 : 0.15),
                        lineWidth: 1.5
                    )
                }
                .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
                .padding(8)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(role.accessibilityLabel)
    }
}

#Preview {
    HStack(spacing: 20) {
        ShelfEditBadge(role: .remove) {}
        ShelfEditBadge(role: .add) {}
        ShelfEditBadge(role: .add, isEnabled: false) {}
    }
    .padding()
    .background(ShelfPalette.background)
}
