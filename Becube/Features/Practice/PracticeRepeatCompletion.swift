//
//  PracticeRepeatCompletion.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 24/08/26.

//
import SwiftUI

struct PracticeRepeatCompletionView: View {
    let skillID: String
    /// The log the practice just wrote — reflecting fills it in rather than adding another.
    let logID: UUID

    @Environment(Router.self) private var router
    @Environment(GardenStore.self) private var gardenStore

    private var practiceCount: Int {
        gardenStore.getPlantAverageRating(id: skillID).count
    }

    var body: some View {
        CommentBox(bulge: 6, tailPosition: .none, contentPadding: 24) { // plain card, no speech-bubble tail — matches your mock-up
            VStack(spacing: 20) {
                Text("Skill Practiced!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.text)

                Text("You have now done this skill")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.secondary)

                ZStack {
                    Image("Indicator")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                    Text("\(practiceCount)x")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 12) {
                    Button {
                        router.repeatCompletion = nil
                        router.reflectAfterPractice(skillID: skillID, logID: logID)
                    } label: {
                        filledButtonLabel("Log Experience")
                    }
                    Button {
                        router.exitFlow() // clears the card as it leaves the loop
                    } label: {
                        outlinedButtonLabel("Close")
                    }
                }
            }
        }
    }

    private func filledButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.text)
            .clipShape(Capsule())
    }

    private func outlinedButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.text)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.text, lineWidth: 1)
            )
    }
}
