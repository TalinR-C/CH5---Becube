//
//  Components.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 19/08/26.
//

import SwiftUI

enum TailPosition: Int {
    case none = 0
    case bottomCenter = 1
    case topCenter = 2
    case bottomLeft = 3
    case bottomRight = 4
}

struct BulgingCardShape: Shape {
    var cornerRadius: CGFloat
    var bulge: CGFloat
    var tailPosition: TailPosition = .none
    var tailWidth: CGFloat = 28
    var tailHeight: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Never let the corner radius exceed half the box's smaller dimension —
        // otherwise the arcs are asked to curve more than the shape physically has room for,
        // which is what caused the spiky self-intersections on small content.
        let cornerRadius = min(self.cornerRadius, rect.width / 2, rect.height / 2)

        // Never let the tail be wider than the straight section of the edge it sits on
        // (the edge's full length, minus the two rounded corners on either side).
        let maxTailWidth = max(0, rect.width - 2 * cornerRadius)
        let tailWidth = min(self.tailWidth, maxTailWidth)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                    radius: cornerRadius)

        if tailPosition == .topCenter {
            addEdgeWithTail(
                to: &path,
                from: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
                to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY),
                tailCenterX: rect.midX,
                tailPointsUp: true,
                tailWidth: tailWidth
            )
        } else {
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY),
                control: CGPoint(x: rect.midX, y: rect.minY - bulge)
            )
        }

        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
                    radius: cornerRadius)

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))

        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                    radius: cornerRadius)

        let bottomTailCenterX: CGFloat
        switch tailPosition {
        case .bottomLeft: bottomTailCenterX = rect.minX + rect.width * 0.25
        case .bottomRight: bottomTailCenterX = rect.minX + rect.width * 0.75
        default: bottomTailCenterX = rect.midX
        }

        let hasBottomTail = tailPosition == .bottomCenter
            || tailPosition == .bottomLeft
            || tailPosition == .bottomRight

        if hasBottomTail {
            addEdgeWithTail(
                to: &path,
                from: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
                to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY),
                tailCenterX: bottomTailCenterX,
                tailPointsUp: false,
                tailWidth: tailWidth
            )
        } else {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY),
                control: CGPoint(x: rect.midX, y: rect.maxY + bulge)
            )
        }

        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
                    radius: cornerRadius)

        path.closeSubpath()

        return path
    }

    private func addEdgeWithTail(
        to path: inout Path,
        from start: CGPoint,
        to end: CGPoint,
        tailCenterX: CGFloat,
        tailPointsUp: Bool,
        tailWidth: CGFloat // now passed in as the already-clamped value, instead of read from self
    ) {
        let travelingRight = end.x > start.x
        let halfWidth = tailWidth / 2

        let tailStartX = tailCenterX - (travelingRight ? halfWidth : -halfWidth)
        let tailEndX = tailCenterX + (travelingRight ? halfWidth : -halfWidth)

        let edgeY = start.y
        let tipY = tailPointsUp ? edgeY - tailHeight : edgeY + tailHeight

        path.addLine(to: CGPoint(x: tailStartX, y: edgeY))
        path.addLine(to: CGPoint(x: tailCenterX, y: tipY))
        path.addLine(to: CGPoint(x: tailEndX, y: edgeY))
        path.addLine(to: end)
    }
}


struct BulgingCard<Content: View>: View {
    var tailPosition: TailPosition = .none
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(24)
            .background(
                BulgingCardShape(cornerRadius: 40, bulge: 6, tailPosition: tailPosition)
                    .stroke(Color.brown, lineWidth: 2)
            )
            .padding(8)
            .background(
                BulgingCardShape(cornerRadius: 48, bulge: 8, tailPosition: tailPosition)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
    }
}
