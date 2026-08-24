//
//  EmptyToolSlot.swift
//  Becube
//
//  A free place on the Shelf's toolbox plank, drawn as a dashed pot outline. The row
//  always shows `ToolkitService.capacity` slots, so the shelf reads as four places to
//  fill rather than as a row that happens to be short.
//

import SwiftUI

/// Geometry shared by the toolbox row's filled and empty slots, so the two line up on
/// the plank whichever mix the shelf happens to be showing.
enum ToolboxSlot {
    /// Width of a card's name bubble. Fixed (not `maxWidth`) so every bubble in the row
    /// is exactly the same width, as in the Hi-Fi — and narrow enough that four slots fit
    /// across the plank before the row would need to scroll.
    static let nameWidth: CGFloat = 60

    /// Full drawn width of one slot: `nameWidth` plus the content padding and outline
    /// inset `CommentBox` adds on each side of it.
    static let width: CGFloat = nameWidth + 2 * (6 + 8)

    /// How far a filled card's badges hang below the base of its plant art. An empty slot
    /// reserves the same space under its pot, so with the row bottom-aligned both sit at
    /// the same height on the plank.
    ///
    /// This doubles as how far the badges overlap the pot (`badgeSize - baseDrop`), so
    /// reach for `plankLift` below to move the plants up or down the plank — it leaves
    /// that overlap alone.
    static let baseDrop: CGFloat = 16

    /// How far the whole row stands up off the bottom of the plank. Raising this lifts the
    /// plants and the dashed empty slots together, higher against the shelf; lowering it
    /// sinks them further behind the plank's front edge.
    static let plankLift: CGFloat = 16

    /// An extra lift applied to a filled `ToolBoxPlantCard` only, on top of `plankLift`.
    /// The card moves as a whole — plant, pot and both indicator badges — so a collected
    /// plant sits a touch higher than the empty places beside it.
    static let cardLift: CGFloat = 8
}

struct EmptyToolSlot: View {
    /// Height of the dashed pot. The artwork is 55x43, so this draws it at close to the
    /// size it was designed at.
    private let potHeight: CGFloat = 44

    var body: some View {
        Image("EmptyStateToolFlower")
            .resizable()
            .scaledToFit()
            .frame(height: potHeight)
            .frame(width: ToolboxSlot.width)
            .padding(.bottom, ToolboxSlot.baseDrop)
            .accessibilityLabel("Empty shelf slot")
    }
}

#Preview {
    HStack(alignment: .bottom, spacing: 6) {
        ForEach(0..<4, id: \.self) { _ in EmptyToolSlot() }
    }
    .padding()
    .background(ShelfPalette.background)
}
