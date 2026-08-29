//
//  PracticeCompletionView.swift
//  Becube
//
//  Created by Ni Ketut Lela Berliani on 24/08/26.
//

import SwiftUI

struct PracticeCompletionView: View {
    let skillID: String
    /// The log the practice just wrote — reflecting fills it in rather than adding another.
    let logID: UUID

    @Environment(Router.self) private var router

    private var skill: CopingSkill? {
        ContentRepository.skill(id: skillID)
    }

    var body: some View {
        ZStack{
            Color("Off White")
                .ignoresSafeArea(edges: .all)
            VStack(spacing: 24) {
                Spacer()
                CommentBox(bulge: 6, tailPosition: .bottomCenter, contentPadding: 24) {
                    // tail points down, toward the flower sitting below it
                    VStack(spacing: 8) {
                        Text("Congratulations!")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.text)
                        Text("You've completed a skill! The plant has been brought back from the garden. Feel free to keep practicing and using the skill whenever you need it.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.text)
                    }
                }
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                Image(skill?.plantImageName() ?? CopingSkill.placeholderImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 220)

                VStack(spacing: 5) {
                    Text(skill?.localizedName ?? "")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.text)
                    Text(skill?.localizedPlantName ?? "")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.text)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        router.reflectAfterPractice(skillID: skillID, logID: logID) //continue to reflect
                    } label: {
                        filledButtonLabel("Log your Experience")
                    }
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                    Button {
                        router.exitFlow() // skipping reflection still ends the loop
                    } label: {
                        outlinedButtonLabel("Continue Exploring")
                    }
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
            }
            .padding(24)
        }
        
    }

    private func filledButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.darkBrown)
            .clipShape(Capsule())
    }

    private func outlinedButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .foregroundColor(.text)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        PracticeCompletionView(skillID: "box_breathing", logID: UUID())
            .environment(Router())
    }
}
