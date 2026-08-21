//
//  ChatBubble.swift
//  Becube
//
//  Created by Muhammad Saleh Bagir Alatas on 16/08/26.
//

import SwiftUI

struct SkillBubble: View {
    let message: String
    var bubbleWidth: CGFloat = 150 // Set your exact width here
    var tailOffsetDenominator: CGFloat = 4 // the denominator of this formula that determines the offset of tail from the center of rectangle = (Rectangle Width / Denominator)

    private let brown = Color(red: 158 / 255, green: 110 / 255, blue: 74 / 255)
    private let cream = Color(red: 255 / 255, green: 253 / 255, blue: 248 / 255)

    private var bubbleShape: SkillBubbleShape {
        SkillBubbleShape(tailCenterX: 0.5 + 1 / tailOffsetDenominator)
    }

    var body: some View {
        Text(message)
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .foregroundStyle(brown)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: bubbleWidth, alignment: .center)
            .padding(.bottom, SkillBubbleShape.tailHeight)
            .background(bubbleShape.fill(cream))
            .overlay(bubbleShape.stroke(brown, lineWidth: 2))
            .padding(.horizontal)
    }
}

/// A rounded rectangle speech bubble with the tail merged into the bottom
/// edge, so a single stroke outlines both the body and the tail.
struct SkillBubbleShape: Shape {
    static let tailHeight: CGFloat = 12

    var cornerRadius: CGFloat = 18
    var tailWidth: CGFloat = 14
    var tailCenterX: CGFloat = 0.75 // fraction of the bubble width

    func path(in rect: CGRect) -> Path {
        let body = CGRect(
            x: rect.minX, y: rect.minY,
            width: rect.width, height: rect.height - Self.tailHeight
        )
        let r = min(cornerRadius, min(body.width, body.height) / 2)
        let tailX = rect.minX + rect.width * tailCenterX

        var path = Path()
        path.move(to: CGPoint(x: body.minX + r, y: body.minY))
        path.addLine(to: CGPoint(x: body.maxX - r, y: body.minY))
        path.addArc(
            center: CGPoint(x: body.maxX - r, y: body.minY + r), radius: r,
            startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )
        path.addLine(to: CGPoint(x: body.maxX, y: body.maxY - r))
        path.addArc(
            center: CGPoint(x: body.maxX - r, y: body.maxY - r), radius: r,
            startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false
        )
        path.addLine(to: CGPoint(x: tailX + tailWidth / 2, y: body.maxY))
        path.addQuadCurve(
            to: CGPoint(x: tailX, y: rect.maxY),
            control: CGPoint(x: tailX + tailWidth / 4, y: body.maxY + Self.tailHeight * 0.6)
        )
        path.addQuadCurve(
            to: CGPoint(x: tailX - tailWidth / 2, y: body.maxY),
            control: CGPoint(x: tailX - tailWidth / 4, y: body.maxY + Self.tailHeight * 0.6)
        )
        path.addLine(to: CGPoint(x: body.minX + r, y: body.maxY))
        path.addArc(
            center: CGPoint(x: body.minX + r, y: body.maxY - r), radius: r,
            startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false
        )
        path.addLine(to: CGPoint(x: body.minX, y: body.minY + r))
        path.addArc(
            center: CGPoint(x: body.minX + r, y: body.minY + r), radius: r,
            startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color(.green)

        VStack(spacing: 24) {
            SkillBubble(message: "Name your Feeling")
            SkillBubble(message: "Lorem ipsum dolor sit amet Lo rem ipsum dolor sit amet Lorem ipsum dolor sit amet", tailOffsetDenominator: -4)
        }
    }
}
