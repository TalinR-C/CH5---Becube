//
//  CommentBox.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 19/08/26.
//
//  Shared version of the "captionCard" that used to live privately inside
//  LearnView. Pulled out here so any feature can show a brown-outlined,
//  speech-bubble-style text box without redefining it.
//

import SwiftUI

/// A rounded, slightly "bulging" card with an optional speech-bubble tail — the
/// brown-outlined box used throughout the Learn flow and the Shelf's toolbox row.
///
/// The card is drawn as two stacked `BulgingCardShape`s: a thin stroked outline sized
/// to fit its content, and a slightly larger filled shape behind it that gives the
/// soft drop shadow and the "double outline" look. The outer shape's corner radius and
/// bulge are derived from the inner ones (see `outerRadiusStep` / `outerBulgeStep`) so
/// the two layers always stay visually consistent, no matter what values you pass in.
///
/// `CommentBox` is generic over its content, the same way `Button` or `Label` are —
/// pass any `View` and it gets wrapped in the bubble as-is, so the size, weight, color,
/// or even whether it's text at all is entirely up to the caller:
///
/// ```swift
/// // Any View works — not just Text.
/// CommentBox(cornerRadius: 20, tailPosition: .bottomLeft) {
///     Text("Box Breathing")
///         .font(.system(size: 20, weight: .heavy, design: .rounded))
///         .foregroundStyle(.purple)
/// }
/// ```
///
/// For the common case — plain text at the box's original default style — use the
/// `text:` convenience initializer below instead, which is exactly what this used to
/// look like before it became generic:
///
/// ```swift
/// CommentBox(text: "Box Breathing", tailPosition: .topCenter)
///
/// CommentBox(text: "Try 4 seconds in, 4 hold, 4 out.",
///            cornerRadius: 24,
///            bulge: 2,
///            tailPosition: .bottomLeft)
/// ```
struct CommentBox<Content: View>: View {
    let cornerRadius: CGFloat
    let bulge: CGFloat
    let tailPosition: TailPosition
    /// Space between the content and the stroked outline. Defaults to the system
    /// `.padding()` value the original captionCard used; drop it for the small
    /// name bubbles on the Shelf, where 16pt of chrome per side would leave almost
    /// no room for the text.
    let contentPadding: CGFloat
    private let content: Content

    /// How much larger the outer (filled) shape's corner radius is than the inner
    /// (stroked) shape's — matches the 40 → 48 relationship the original captionCard used.
    private let outerRadiusStep: CGFloat = 8
    /// Same idea, but for the bulge amount — matches the original 4 → 6 relationship.
    private let outerBulgeStep: CGFloat = 2
    /// Gap between the stroked inner shape and the filled outer shape.
    private let outlineInset: CGFloat = 8

    init(
        cornerRadius: CGFloat = 40,
        bulge: CGFloat = 4,
        tailPosition: TailPosition = .none,
        contentPadding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.bulge = bulge
        self.tailPosition = tailPosition
        self.contentPadding = contentPadding
        self.content = content()
    }

    var body: some View {
        content
            .padding(contentPadding)
            .background(
                BulgingCardShape(cornerRadius: cornerRadius, bulge: bulge, tailPosition: tailPosition)
                    .stroke(Color.brown, lineWidth: 2)
            )
            .padding(outlineInset)
            .background(
                BulgingCardShape(
                    cornerRadius: cornerRadius + outerRadiusStep,
                    bulge: bulge + outerBulgeStep,
                    tailPosition: tailPosition
                )
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
    }
}

extension CommentBox where Content == Text {
    /// Convenience initializer for plain text at the box's original default style
    /// (size 15, regular weight, rounded, brown). Every existing call site —
    /// `CommentBox(text: "Box Breathing", tailPosition: .topCenter)` — keeps compiling
    /// and looking exactly the same as before `CommentBox` became generic.
    ///
    /// Reach for the generic initializer above instead as soon as you need a different
    /// size, weight, color, more than one line styled differently, or non-text content
    /// (an icon, a `Label`, an `HStack` of several views) inside the bubble.
    init(
        text: String,
        cornerRadius: CGFloat = 40,
        bulge: CGFloat = 4,
        tailPosition: TailPosition = .none,
        contentPadding: CGFloat = 16
    ) {
        self.init(
            cornerRadius: cornerRadius,
            bulge: bulge,
            tailPosition: tailPosition,
            contentPadding: contentPadding
        ) {
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.brown)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        // The `text:` convenience initializer — unchanged from before.
        CommentBox(text: "Box Breathing", tailPosition: .topCenter)
        CommentBox(text: "This is what a default comment box looks like, wrapping onto a second line.")
        CommentBox(text: "Smaller corner radius, flatter bulge.", cornerRadius: 20, bulge: 2, tailPosition: .bottomLeft)

        // The generic initializer — any View, styled however the caller wants.
        CommentBox(cornerRadius: 16, bulge: 2, tailPosition: .bottomCenter) {
            Text("Custom Style")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.purple)
        }
        CommentBox(tailPosition: .bottomRight) {
            Label("With an icon", systemImage: "leaf.fill")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.green)
        }
    }
    .padding()
    .background(Color("LearnBackground"))
}
