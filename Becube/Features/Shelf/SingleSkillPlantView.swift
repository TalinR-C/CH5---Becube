//
//  SingleSkillPlantView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  The detail screen pushed from a Shelf card: the plant standing on its own shelf,
//  its practice stats, a description card, and the actions you can take on it.
//

import SwiftUI
import SwiftData

struct SinglePlantView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SingleSkillPlantViewModel

    /// How far the plant dips below the top of the shelf section, so its pot lands on
    /// the shelf surface (whose painted shadow sits ~20-55pt into `SinglePlantShelf`)
    /// instead of hovering above the front edge.
    private let plantOverlap: CGFloat = 44

    /// Ceiling on the blue band above the shelf — see the note where it's applied.
    private let plantAreaMaxHeight: CGFloat = 250

    var body: some View {
        ZStack(alignment: .top) {
            ShelfPalette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Capped rather than fixed: on a normal phone the blue band takes its
                // full height and the shelf starts around a third of the way down, as
                // drawn; on a short screen the shelf section (which has a real minimum
                // height) wins the space instead and the buttons stay on screen.
                plantArea
                    .frame(maxWidth: .infinity, maxHeight: plantAreaMaxHeight)
                    // Draw above the shelf below it, so the pot can overlap the shelf lip.
                    .zIndex(1)

                detailArea
            }
        }
        .navigationBarBackButtonHidden(true)
        // This screen is pushed inside the Shelf tab's NavigationStack, so the tab bar
        // would otherwise stay visible underneath it.
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .tint(ShelfPalette.darkBrown)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "clock")
                }
                .tint(ShelfPalette.darkBrown)
            }
        }
        .task {
            viewModel.loadSkill()
        }
    }

    // MARK: - Plant

    private var plantArea: some View {
        ZStack(alignment: .top) {
            // No plant art exists per-skill yet, so every skill falls back to the
            // shared "Flower" placeholder image (per Talin's note).
            Image("Flower")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 80)
                .padding(.top, 8)
                // `offset` is a draw-time nudge, so dipping the plant into the shelf
                // doesn't change the layout height the blue area reserves for it.
                .offset(y: plantOverlap)

            HStack {
                Spacer()
                statsColumn
            }
            .padding(.trailing, 26)
            .padding(.top, 28)
        }
    }

    private var statsColumn: some View {
        VStack(spacing: 14) {
            statBlock(label: "Done") {
                Text("\(viewModel.stats.count)x")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown)
            }
            statBlock(label: "Avg\nRating") {
                Image(RatingAsset.assetName(forAverage: viewModel.stats.average))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
            }
        }
    }

    private func statBlock<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown.opacity(0.85))
                .multilineTextAlignment(.center)
            IndicatorBadge(size: 44, content: content)
        }
    }

    // MARK: - Shelf + details

    private var detailArea: some View {
        VStack(spacing: 0) {
            detailCard
            Spacer(minLength: 26)
            actionButtons
        }
        // Clears the shelf's painted front edge so the card's tail points back up at
        // the pot rather than starting halfway down the wall.
        .padding(.top, 46)
        .padding(.bottom, 28)
        // Takes every point the plant area didn't, which is what both stretches the
        // shelf artwork to the bottom of the screen and lets the Spacer above push the
        // buttons down to sit near it.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .top) {
            Image("SinglePlantShelf")
                // The top 145pt of the asset — shelf surface, front face and the dark
                // shadow line — is held at its drawn size; only the flat wall beneath
                // it stretches, so the shelf reaches the bottom of any screen without
                // the edge artwork smearing.
                .resizable(
                    capInsets: EdgeInsets(top: 145, leading: 0, bottom: 0, trailing: 0),
                    resizingMode: .stretch
                )
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var detailCard: some View {
        CommentBox(cornerRadius: 34, bulge: 3, tailPosition: .topCenter, contentPadding: 18) {
            VStack(spacing: 6) {
                Text(viewModel.skill?.name ?? "")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown)
                    .multilineTextAlignment(.center)

                // Only rendered once a skill actually carries a plantName — see the
                // property's note in CopingSkill.
                if let plantName = viewModel.skill?.plantName {
                    Text("Flower Name: \(plantName)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .italic()
                        .foregroundStyle(ShelfPalette.darkBrown.opacity(0.9))
                }

                Text(viewModel.skillDescription)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 18)
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button("Practice") {}
                .buttonStyle(ShelfActionButtonStyle(role: .primary))
            Button("Log Experience") {}
                .buttonStyle(ShelfActionButtonStyle(role: .secondary))
            Button("Refresh Your Memory") {}
                .buttonStyle(ShelfActionButtonStyle(role: .secondary))
        }
        .padding(.horizontal, 44)
    }
}

/// The two pill buttons at the bottom of the single-plant screen: one filled action and
/// the lighter variants beside it.
struct ShelfActionButtonStyle: ButtonStyle {
    enum Role { case primary, secondary }

    let role: Role

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(role == .primary ? Color.white : ShelfPalette.darkBrown)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                (role == .primary ? ShelfPalette.buttonPrimary : ShelfPalette.buttonSecondary),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = GardenStore(context: container.mainContext)
    let skillID = ContentRepository.skills.first?.id ?? ""

    return NavigationStack {
        SinglePlantView(viewModel: SingleSkillPlantViewModel(gardenStore: store, skillID: skillID))
    }
}
