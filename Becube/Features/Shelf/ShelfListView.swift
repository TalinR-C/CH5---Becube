//
//  ShelfListView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//

import SwiftUI
import SwiftData

struct ShelfListView: View {
    @State var viewModel: ShelfListViewModel

    // The Shelf tab's NavigationStack lives in RootView, so this view is just
    // its root content.
    var body: some View {
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
                    withAnimation(.snappy(duration: 0.25)) {
                        viewModel.isEditing.toggle()
                    }
                }
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(ShelfPalette.darkBrown)
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
    ///
    /// The row always draws four places: a card for each pinned skill, then a dashed
    /// `EmptyToolSlot` for every one still free. When none are taken the hint bubble
    /// above points down at them.
    private var plankSection: some View {
        VStack(spacing: 8) {
            if viewModel.showsToolboxHint {
                toolboxHint
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottom)))
            }

            plankRow
        }
    }

    private var plankRow: some View {
        ZStack(alignment: .bottom) {
            Image("Shelf")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)

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
                    // While editing, the card itself stops being a link so a tap can't
                    // navigate away mid-rearrange. Applied *before* the overlay so the
                    // badge on top of it stays tappable.
                    .allowsHitTesting(!viewModel.isEditing)
                    .overlay(alignment: .topLeading) {
                        if viewModel.isEditing {
                            ShelfEditBadge(role: .remove) {
                                withAnimation(.snappy(duration: 0.25)) {
                                    viewModel.unpin(skill.id)
                                }
                            }
                            .offset(x: -14, y: -14)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                ForEach(Array(0..<viewModel.emptyToolboxSlotCount), id: \.self) { _ in
                    EmptyToolSlot()
                }
            }
            .padding(.horizontal, 8)
        }
    }

    /// Only on screen while the plank is bare. Drawn as a bare `BulgingCardShape` rather
    /// than a `CommentBox` because this bubble is outline-only against the page's blue,
    /// and `CommentBox` always paints a white card behind its stroke.
    private var toolboxHint: some View {
        Text("Press edit to add the plants that you find most useful on the shelf")
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(ShelfPalette.paperBorder)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                BulgingCardShape(
                    cornerRadius: 24,
                    bulge: 2,
                    tailPosition: .bottomCenter,
                    tailWidth: 22,
                    tailHeight: 14
                )
                .stroke(ShelfPalette.paperBorder, lineWidth: 2)
            }
            // The tail is drawn below the shape's own rect, so the bubble has to reserve
            // that height itself or it would overlap the plants underneath it.
            .padding(.bottom, 16)
            .accessibilityElement()
            .accessibilityLabel("Press edit to add the plants that you find most useful on the shelf")
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
                    .allowsHitTesting(!viewModel.isEditing)
                    .overlay(alignment: .topLeading) {
                        // A plant already on the plank gets no badge at all — the row
                        // above is where it's taken back off.
                        if viewModel.isEditing, !viewModel.isPinned(skill.id) {
                            ShelfEditBadge(role: .add, isEnabled: viewModel.toolboxHasRoom) {
                                withAnimation(.snappy(duration: 0.25)) {
                                    viewModel.pin(skill.id)
                                }
                            }
                            .offset(x: -14, y: -14)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }

            if viewModel.filteredSkills.isEmpty {
                noResults
            }
        }
        .padding(.horizontal, paperInset)
        .padding(.top, 30)
        .padding(.bottom, 36)
        // Keeps the sheet looking like a sheet when only a card or two is unlocked —
        // without it the two torn end pieces alone are taller than the content and the
        // stretchable middle would collapse to nothing. Top-aligned so the heading and
        // search field stay put instead of drifting down the sheet when the grid empties.
        .frame(minHeight: 340, alignment: .top)
        .background(paperBackground)
    }

    private var noResults: some View {
        Text("No plants match “\(viewModel.searchText)”.")
            .font(.system(size: 15, design: .rounded))
            .foregroundStyle(ShelfPalette.darkBrown.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.top, 12)
    }

    /// Drawn aspect ratios of the two torn end pieces (TopShelf is 400x128,
    /// BottomShelf 400x133), used below to give each one a definite height.
    private static let topEdgeRatio: CGFloat = 400 / 128
    private static let bottomEdgeRatio: CGFloat = 400 / 133

    /// The torn-paper sheet, assembled from its three pieces: the torn top edge, a
    /// middle section stretched to whatever height the content needs, and the torn
    /// bottom edge. This is what lets the sheet grow with the number of unlocked plants.
    ///
    /// The end pieces are sized from the sheet's width rather than left to `scaledToFit`.
    /// Fitting means fitting in *both* axes, so each piece shrank to whatever slice of
    /// height the `VStack` handed it and came out narrower than the stretched middle —
    /// the sheet looked pinched at the top and bottom. Deriving the height from the width
    /// instead keeps both ends edge-to-edge at their drawn proportions.
    private var paperBackground: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            VStack(spacing: 0) {
                tornEdge("TopShelf", width: width, ratio: Self.topEdgeRatio)

                Image("MiddleShelf")
                    // Caps hold the torn left and right borders at their drawn width; only
                    // the flat paper between them stretches horizontally.
                    .resizable(
                        capInsets: EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30),
                        resizingMode: .stretch
                    )
                    .frame(maxHeight: .infinity)

                tornEdge("BottomShelf", width: width, ratio: Self.bottomEdgeRatio)
            }
        }
    }

    private func tornEdge(_ name: String, width: CGFloat, ratio: CGFloat) -> some View {
        Image(name)
            .resizable()
            .frame(width: width, height: width / ratio)
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

/// - Parameter pinnedCount: how many plants start on the toolbox plank, which is what
///   the three previews below vary — a full shelf, a part-filled one, and a bare one.
@MainActor
private func previewShelf(pinnedCount: Int) -> some View {
    let container = try! ModelContainer(
        for: GardenState.self, Log.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = GardenStore(context: container.mainContext)
    store.gardenState.name = "David"
    store.gardenState.unlockedToolboxID = ContentRepository.skills.prefix(pinnedCount).map(\.id)
    store.gardenState.unlockedPlantsID = ContentRepository.skills.map(\.id)
    return NavigationStack {
        ShelfListView(viewModel: ShelfListViewModel(gardenStore: store))
    }
}

#Preview("Full shelf") {
    previewShelf(pinnedCount: 4)
}

#Preview("Part-filled shelf") {
    previewShelf(pinnedCount: 2)
}

#Preview("Empty shelf") {
    previewShelf(pinnedCount: 0)
}
