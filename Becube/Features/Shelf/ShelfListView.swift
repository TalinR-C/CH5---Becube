//
//  ShelfListView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData


struct ShelfListView: View {
    @Environment(GardenStore.self) private var gardenStore
    @State var viewModel: ShelfListViewModel

    // The Shelf tab's NavigationStack lives in RootView, so this view is just
    // its root content.
    var body: some View {
        ZStack{
            ScrollView {
                VStack(spacing: 0) {
                    titleSign
                    plankSection
                        // Drawn above the sheet so the plank's front edge sits on top
                        // of the paper's torn top, rather than the other way round.
                        .zIndex(1)
                    paperSection
                        // Tucks the sheet up under the plank so the blue only shows
                        // through the torn notches, not as a band between the two.
                        .padding(.top, -8)
                }
            }
            .scrollIndicators(.hidden)
            .background(ShelfPalette.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isEditing ? "Done" : "Edit") {
                        viewModel.isEditing.toggle()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown)
                }
            }
        }
    }

    // MARK: - Title

    /// Height of the hanging sign. Fixed rather than proportional so `titleOffset`
    /// below can be derived from it.
    private let signHeight: CGFloat = 150

    private var titleSign: some View {
        Image("Title")
            .resizable()
            .scaledToFit()
            .frame(height: signHeight)
            .overlay {
                Text(viewModel.shelfTitle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(ShelfPalette.darkBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 48)
                    // Title.png is 363x168, of which the top ~40% is rope — the board's
                    // visual centre sits at ~64% of the image height, not 50%. Nudging
                    // the text down by that difference lands it on the wood instead of
                    // floating up over the ropes.
                    .offset(y: signHeight * 0.14)
            }
            .padding(.top, 8)
    }

    // MARK: - Toolbox plank

    /// The pinned skills stand on the `Shelf` plank, which is bottom-aligned behind the
    /// row so the pots disappear behind its front edge and the badges straddle it.
    private var plankSection: some View {
        ZStack(alignment: .bottom) {
            Image("Shelf")
                .resizable()
                .scaledToFit()

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(viewModel.toolboxSkills) { skill in
                        let stats = viewModel.stats(for: skill.id)
                        NavigationLink(value: Route.skillDetail(skillID: skill.id)) {
                            ToolBoxPlantCard(
                                name: skill.name,
                                averageRating: stats.average,
                                timesCompleted: stats.count
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
        }
    }

    // MARK: - Paper sheet

    /// Inset from the paper's edge to its content. The artwork's own torn border eats
    /// the outer ~3% of the image, so this clears that plus a comfortable margin.
    private let paperInset: CGFloat = 44

    private var paperSection: some View {
        VStack(spacing: 16) {
            Text("Plants Collected")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown)

            searchBar

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(viewModel.filteredSkills) { skill in
                    let stats = viewModel.stats(for: skill.id)
                    NavigationLink(value: Route.skillDetail(skillID: skill.id)) {
                        PlantCard(
                            name: skill.name,
                            averageRating: stats.average,
                            timesCompleted: stats.count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, paperInset)
        .padding(.top, 30)
        .padding(.bottom, 36)
        // Keeps the sheet looking like a sheet when only a card or two is unlocked —
        // without it the two torn end pieces alone are taller than the content and the
        // stretchable middle would collapse to nothing.
        .frame(minHeight: 320)
        .background(paperBackground)
    }

    /// The torn-paper sheet, assembled from its three pieces: the torn top edge, a
    /// middle section stretched to whatever height the content needs, and the torn
    /// bottom edge. This is what lets the sheet grow with the number of unlocked plants.
    private var paperBackground: some View {
        VStack(spacing: 0) {
            Image("TopShelf")
                .resizable()
                .scaledToFit()

            Image("MiddleShelf")
                // Caps hold the torn left and right borders at their drawn width; only
                // the flat paper between them stretches horizontally.
                .resizable(
                    capInsets: EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30),
                    resizingMode: .stretch
                )
                .frame(maxHeight: .infinity)

            Image("BottomShelf")
                .resizable()
                .scaledToFit()
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ShelfPalette.darkBrown.opacity(0.55))
            TextField("Search", text: $viewModel.searchText)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ShelfPalette.darkBrown.opacity(0.55))
                }
            } else {
                Image(systemName: "mic.fill")
                    .foregroundStyle(ShelfPalette.darkBrown.opacity(0.55))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white, in: Capsule())
        .overlay(Capsule().stroke(ShelfPalette.paperBorder, lineWidth: 1.5))
    }
}

/// Colours sampled straight out of the paper and shelf artwork, so anything drawn
/// alongside it (cards, the search field) matches instead of being eyeballed.
enum ShelfPalette {
    /// Page background behind the sign and the plants.
    static let background = Color(red: 0.80, green: 0.90, blue: 0.95)
    /// The cream fill of the torn paper sheet.
    static let paperFill = Color(red: 250 / 255, green: 245 / 255, blue: 234 / 255)
    /// The brown line that outlines the paper — reused for card and search borders.
    static let paperBorder = Color(red: 156 / 255, green: 112 / 255, blue: 76 / 255)
    /// Text colour used on the sign and the cards.
    static let darkBrown = Color("Dark Brown")
    /// Text sitting on top of an `Indicator` badge, which is dark.
    static let badgeText = Color.white
    /// Filled action button on the single-plant screen.
    static let buttonPrimary = Color(red: 122 / 255, green: 82 / 255, blue: 48 / 255)
    /// The lighter action button sitting beneath it. Near-white rather than tan, since
    /// it now reads against the page's blue instead of a brown shelf wall.
    static let buttonSecondary = Color.white
}

#Preview {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = GardenStore(context: container.mainContext)
    store.gardenState.name = "David"
    store.gardenState.unlockedToolboxID = ContentRepository.skills.prefix(4).map(\.id)
    store.gardenState.unlockedPlantsID = ContentRepository.skills.map(\.id)
    return NavigationStack {
        ShelfListView(viewModel: ShelfListViewModel(gardenStore: store))
    }
}
