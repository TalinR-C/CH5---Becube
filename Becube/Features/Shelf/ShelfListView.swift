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

    // MARK: - Sheet state

    /// Whether the paper is up over the whole screen or down showing the shelf.
    @State private var isSheetRaised = false

    /// Height of the fixed backdrop — the sign plus the plank — measured rather than
    /// added up by hand, so the paper keeps tucking under the plank's front edge however
    /// the artwork above it is retuned.
    @State private var backdropHeight: CGFloat = 0

    /// Live finger movement, on top of whichever position the sheet is resting at.
    @State private var dragTranslation: CGFloat = 0

    /// The furthest the grid was pulled past its top during the current interaction.
    ///
    /// Needed because the scroll view starts springing back the instant the finger lifts,
    /// so by the time the phase settles `dragTranslation` has already been driven back to
    /// zero — reading it then would say the user never pulled at all.
    @State private var peakPull: CGFloat = 0

    /// How far the paper's top edge sits below the screen's top when raised, leaving the
    /// sign's ropes showing above it.
    private let raisedTopInset: CGFloat = 40

    /// Overlap that tucks the paper under the plank's front edge when it's down, so the
    /// blue only shows through the torn notches rather than as a band between the two.
    private let plankOverlap: CGFloat = 8

    private var collapsedTop: CGFloat { max(raisedTopInset, backdropHeight - plankOverlap) }

    /// Where the paper's top edge is right now: its resting position, moved by the drag in
    /// progress, and never past either end stop.
    private var sheetTop: CGFloat {
        let resting = isSheetRaised ? raisedTopInset : collapsedTop
        return min(collapsedTop, max(raisedTopInset, resting + dragTranslation))
    }

    // The Shelf tab's NavigationStack lives in RootView, so this view is just
    // its root content.
    var body: some View {
        // The button is a sibling of the page rather than an overlay on it so the two can
        // treat the safe area differently: the backdrop runs up behind the status bar,
        // while the button stays clear of it.
        ZStack(alignment: .topTrailing) {
            backdrop
            paperSheet
            editButton
        }
        .background(ShelfPalette.background.ignoresSafeArea())
        // The Shelf runs its own Edit button rather than a navigation bar. A bar would do
        // two unwanted things here: reserve a strip of height above the ropes, and lay its
        // translucent material over the page's blue as content scrolls under it — the fade
        // at the top of the shelf. The other full-bleed screens (LearnView,
        // PracticeHostView) hide it the same way.
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Backdrop

    /// The sign and the toolbox plank. Fixed: the paper slides over it, it never moves.
    private var backdrop: some View {
        VStack(spacing: 0) {
            titleSign
            plankSection
        }
        // Measured on the sign-and-plank stack itself, before it's pinned to the top of a
        // full-height frame — that frame's height would be the whole screen.
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { backdropHeight = $0 }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.container, edges: .top)
    }

    // MARK: - Paper sheet

    /// The torn paper, sliding between the two positions. Its height is whatever is left
    /// below `sheetTop`, so it always reaches the bottom of the screen — raising it grows
    /// the sheet rather than lifting a fixed-height card and leaving a gap underneath.
    private var paperSheet: some View {
        paperSection
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, sheetTop)
            .ignoresSafeArea(.container, edges: .top)
            .gesture(sheetDrag)
    }

    /// Drags the whole sheet, from anywhere on the paper that isn't the scrolling grid —
    /// the heading, the search field, the margins. SwiftUI gives a child's own gesture
    /// priority over a parent's `.gesture`, so a drag that starts on the cards still goes
    /// to the grid whenever the grid is scrollable, and this only picks up what's left.
    ///
    /// Which leaves one gap: a drag that starts on the cards while the sheet is up. That
    /// belongs to the grid's scrolling, so lowering from there is driven by its overscroll
    /// instead (see `plantGrid`) — pull past the top and the sheet takes over.
    private var sheetDrag: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                let travelled = value.translation.height
                // Down, only an upward drag moves anything; up, only a downward one.
                dragTranslation = isSheetRaised ? max(0, travelled) : min(0, travelled)
            }
            .onEnded { value in
                let willTravel = value.predictedEndTranslation.height
                withAnimation(.snappy(duration: 0.35, extraBounce: 0.08)) {
                    if isSheetRaised {
                        if willTravel > 80 { isSheetRaised = false }
                    } else if willTravel < -80 {
                        isSheetRaised = true
                    }
                    dragTranslation = 0
                }
            }
    }

    /// Sits in the safe area's top-right corner, over the sign's ropes, and stays put while
    /// the page scrolls underneath it.
    private var editButton: some View {
        Button(viewModel.isEditing ? "Done" : "Edit") {
            withAnimation(.snappy(duration: 0.25)) {
                viewModel.isEditing.toggle()
            }
        }
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundStyle(ShelfPalette.darkBrown)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(ShelfPalette.buttonSecondary, in: Capsule())
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.trailing, 16)
        .padding(.top, 8)
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
                    .font(.custom("Jua Regular", size: 30))
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
            // The plank is bottom-aligned behind the row, so padding the row's bottom is
            // what stands the whole thing — plants and empty slots alike — up off it.
            .padding(.bottom, ToolboxSlot.plankLift)
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

    /// Header and search field are pinned to the top of the sheet; only `plantGrid`
    /// underneath them scrolls.
    private var paperSection: some View {
        VStack(spacing: 16) {
            Text("Plants Collected")
                .font(.custom("Jua-Regular", size: 20))
                .foregroundStyle(ShelfPalette.darkBrown)

            searchBar
                .padding(.horizontal, paperInset)

            plantGrid
        }
        .padding(.top, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(paperBackground)
    }

    private var plantGrid: some View {
        ScrollView {
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
        // Inset the *content*, not the ScrollView. Padding the scroll view itself would
        // pull its clipping bounds in to the cards' own edges, and the edit badges — which
        // hang 14pt up and to the left of each card — would be clipped away.
        .padding(.horizontal, paperInset)
        .padding(.top, 16)
        .padding(.bottom, 36)
        .scrollIndicators(.hidden)
        // Down, the grid doesn't scroll — the upward drag belongs to the sheet, so raising
        // it is the first thing that happens, exactly as a Maps-style sheet behaves.
        .scrollDisabled(!isSheetRaised)
        // Guarantees the overscroll below exists even with only a card or two collected;
        // without it a short grid wouldn't bounce and the sheet couldn't be pulled down.
        .scrollBounceBehavior(.always)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            // How far the grid has been pulled past its own top. Measured against the
            // content inset rather than raw `contentOffset`, which is only zero at rest
            // when the scroll view happens to have no insets of its own.
            max(0, geometry.contentInsets.top - geometry.contentOffset.y)
        } action: { _, pull in
            // Pulling the grid down past its top hands the movement over to the sheet,
            // which is what makes lowering it feel like one continuous gesture rather
            // than a separate thing to grab.
            guard isSheetRaised else { return }
            dragTranslation = pull
            peakPull = max(peakPull, pull)
        }
        .onScrollPhaseChange { oldPhase, _ in
            // Decide the moment the finger lifts, not when the scroll finally settles —
            // by then the spring-back has already reset everything.
            guard isSheetRaised, oldPhase == .interacting else { return }
            withAnimation(.snappy(duration: 0.35, extraBounce: 0.08)) {
                if peakPull > 80 { isSheetRaised = false }
                dragTranslation = 0
            }
            peakPull = 0
        }
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
                .font(.custom("SFProRounded-Medium", size: 16))
                .foregroundStyle(ShelfPalette.darkBrown)
            // Nothing sits on the trailing side until there's something to clear.
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ShelfPalette.darkBrown.opacity(0.55))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
                .transition(.opacity)
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
