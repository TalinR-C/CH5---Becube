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

    /// How many `PlantCard`s sit on each `MiddleShelf` plank — matches the 2-column
    /// layout in the Hi-Fi.
    private let cardsPerRow = 2

    var body: some View {
        NavigationStack {
            ScrollView {
                // spacing 0 everywhere: the three shelf assets are drawn to butt directly
                // against each other, so any gap would show the blue background through
                // the middle of what should read as one continuous piece of furniture.
                VStack(spacing: 0) {
                    titleSign
                    toolboxShelf
                    searchStrip
                    ForEach(Array(shelfRows.enumerated()), id: \.offset) { _, row in
                        shelfRow(row)
                    }
                    Image("BottomShelf")
                        .resizable()
                        .scaledToFit()
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
            // One destination declared once for the whole stack — every card below
            // (toolbox row or shelf grid) navigates by pushing a skill id onto it.
            .navigationDestination(for: String.self) { skillID in
                SinglePlantView(viewModel: viewModel.singleSkillViewModel(for: skillID))
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

    // MARK: - Toolbox row

    /// The pinned skills stand *on* the top shelf: `TopShelf` is bottom-aligned behind
    /// the row so the plants' pots disappear behind the plank's front edge and their
    /// badges sit on the plank face, exactly as in the Hi-Fi.
    private var toolboxShelf: some View {
        ZStack(alignment: .bottom) {
            Image("TopShelf")
                .resizable()
                .scaledToFit()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(viewModel.toolboxSkills) { skill in
                        let stats = viewModel.stats(for: skill.id)
                        NavigationLink(value: skill.id) {
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
            // Lifts the badges off the bottom of the plank and onto its lighter front
            // face (that band sits ~19-41pt up from TopShelf's bottom edge at full width).
            .padding(.bottom, 22)
        }
        // TopShelf's dark under-strip stops ~9pt short of each edge, which would let the
        // blue page background show through in the corners between the plank and the
        // shelf below. Painting the interior behind that strip closes the gap so the
        // whole unit reads as one continuous piece.
        .background(alignment: .bottom) {
            ShelfPalette.interiorWithRails.frame(height: 22)
        }
    }

    // MARK: - Search

    /// The search field sits inside the shelf opening, on the dark interior — so this
    /// strip paints `ShelfPalette.interior` behind it and butts straight up against the
    /// first `MiddleShelf` below.
    private var searchStrip: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $viewModel.searchText)
                .font(.system(size: 17, design: .rounded))
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            } else {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemGray5), in: Capsule())
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(ShelfPalette.interiorWithRails)
    }

    // MARK: - Shelf rows

    /// One `MiddleShelf` per row of cards. The plank is used as a *stretchable*
    /// background rather than a fixed-aspect image, so a row is always exactly as tall
    /// as the cards standing on it — that's what makes the shelf grow to fit however
    /// many skills are unlocked without cards spilling over the plank below.
    private func shelfRow(_ skills: [CopingSkill]) -> some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(skills) { skill in
                let stats = viewModel.stats(for: skill.id)
                NavigationLink(value: skill.id) {
                    PlantCard(
                        name: skill.name,
                        averageRating: stats.average,
                        timesCompleted: stats.count,
                        plantID: skill.id
                    )
                }
                .buttonStyle(.plain)
            }
            // Keeps a half-empty last row left-aligned instead of letting one card
            // stretch across the whole shelf.
            if skills.count < cardsPerRow {
                ForEach(0..<(cardsPerRow - skills.count), id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 24)
        // Drops the cards below the shelf's rail (which spans y≈36-59 of MiddleShelf's
        // 214pt height) so each binder clip straddles the rail rather than floating
        // above it in mid-air.
        .padding(.top, 52)
        .padding(.bottom, 20)
        .background(
            Image("MiddleShelf")
                // Caps protect the artwork that must not distort — the top rail arc and
                // the tan side rails — while the flat interior between them stretches to
                // whatever height the cards need.
                .resizable(
                    capInsets: EdgeInsets(top: 65, leading: 50, bottom: 20, trailing: 50),
                    resizingMode: .stretch
                )
        )
    }

    /// Splits the filtered skills into rows of `cardsPerRow`, so we know how many
    /// `MiddleShelf` planks to draw.
    private var shelfRows: [[CopingSkill]] {
        stride(from: 0, to: viewModel.filteredSkills.count, by: cardsPerRow).map { start in
            let end = min(start + cardsPerRow, viewModel.filteredSkills.count)
            return Array(viewModel.filteredSkills[start..<end])
        }
    }
}

/// Colours sampled straight out of the shelf artwork, so anything drawn *between* the
/// shelf images (the search strip) matches them seamlessly instead of being eyeballed.
enum ShelfPalette {
    /// The dark interior of the shelf — `MiddleShelf`'s flat centre.
    static let interior = Color(red: 129 / 255, green: 93 / 255, blue: 56 / 255)
    /// The bright tan of the shelf's vertical side rails.
    static let rail = Color(red: 215 / 255, green: 166 / 255, blue: 107 / 255)
    /// Page background behind the sign and the plants.
    static let background = Color(red: 0.80, green: 0.90, blue: 0.95)
    /// Text colour used on the sign and the cards.
    static let darkBrown = Color("Dark Brown")
    /// Filled action button on the single-plant screen.
    static let buttonPrimary = Color(red: 122 / 255, green: 82 / 255, blue: 48 / 255)
    /// The lighter action buttons sitting beneath it.
    static let buttonSecondary = Color(red: 219 / 255, green: 208 / 255, blue: 191 / 255)

    /// Reproduces `MiddleShelf`'s horizontal profile — bright rail, quick falloff, flat
    /// interior, and back out again — at any height, so the search strip reads as part
    /// of the same piece of furniture as the planks above and below it.
    static let interiorWithRails = LinearGradient(
        stops: [
            .init(color: rail, location: 0.00),
            .init(color: rail, location: 0.04),
            .init(color: interior, location: 0.12),
            .init(color: interior, location: 0.88),
            .init(color: rail, location: 0.96),
            .init(color: rail, location: 1.00)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
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
    return ShelfListView(viewModel: ShelfListViewModel(gardenStore: store))
}
