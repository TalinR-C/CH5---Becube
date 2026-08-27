//
//  StepChecklist.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//
//  One row of a multi-step practice
//

import SwiftUI

/// Where a step sits in a practice that has several of them.
enum StepState {
    case done, active, upcoming
}

/// One row of a practice checklist: a badge, a title, a line of instruction,
/// and — only while it is the active one — whatever that step actually asks you
/// to do.
///
/// Generic over its expanded content so a practice supplies its own timer,
/// circle or button without this row having to know any of them exist. The tick
/// is the whole point: a step you have finished stays visible above the one you
/// are on, so progress is something you can see rather than remember.
struct StepRow<Expanded: View>: View {

    let number: Int
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    let state: StepState
    let onTap: () -> Void
    @ViewBuilder let expanded: () -> Expanded

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    badge

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            // Jua has a single weight, so no `.semibold`.
                            .font(.custom("Jua-Regular", size: 17))
                            .foregroundStyle(Color.darkBrown)

                        Text(detail)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            // Without this a wrapping line gets truncated inside an HStack.
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            if state == .active {
                expanded()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(state == .active ? 0.85 : 0.45))
        )
    }

    private var badge: some View {
        ZStack {
            Circle()
                .fill(state == .done ? Color.darkBrown : Color.darkBrown.opacity(0.12))
                .frame(width: 30, height: 30)

            if state == .done {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(number)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
            }
        }
    }
}
