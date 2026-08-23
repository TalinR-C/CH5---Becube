//
//  PracticeCompletionView.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 24/08/26.
//

import SwiftUI

struct PracticeCompletionView: View {
    let skillID: String

    @Environment(Router.self) private var router

    private var skill: CopingSkill? {
        ContentRepository.skill(id: skillID)
    }

    var body: some View {
        VStack(spacing: 24) {
            CommentBox(bulge: 6, tailPosition: .bottomCenter, contentPadding: 24) {
                // tail points down, toward the flower sitting below it
                VStack(spacing: 8) {
                    Text("Congratulations!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.darkBrown)
                    Text("You've completed a skill! The plant has been brought back from the garden. Feel free to keep practicing and using the skill whenever you need it.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.darkBrown)
                }
            }

            Image("Flower") // TODO: confirm real asset name with your team
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 220)

            VStack(spacing: 4) {
                Text(skill?.name ?? "")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.darkBrown)
                Text(skill?.plantPhilosophy ?? "") // TODO: field naming still unresolved — see below
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    router.reflectAfterPractice(skillID: skillID) //continue to reflect
                } label: {
                    filledButtonLabel("Log your Experience")
                }

                Button {
                    router.pop() //continue to forest
                } label: {
                    outlinedButtonLabel("Continue Exploring")
                }
            }
        }
        .padding(24)
    }

    private func filledButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.darkBrown)
            .clipShape(Capsule())
    }

    private func outlinedButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.darkBrown)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        PracticeCompletionView(skillID: "box_breathing")
            .environment(Router())
    }
}
