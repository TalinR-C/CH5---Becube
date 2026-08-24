//
//  PracticeHostView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  Chrome: close, skip, completion handoff
//

import SwiftUI

/// The frame every practice runs inside. It owns the background, the title,
/// the close and Done buttons — so a new practice only draws its own
/// animation, and every practice starts, stops and exits identically.
struct PracticeHostView: View {

    let skillID: String

    @Environment(Router.self) private var router
    @Environment(GardenStore.self) private var gardenStore

    /// Built once, in `init`. Building it in `.task` instead would cost a nil
    /// first frame; building it in `body` would hand the content view a fresh
    /// ViewModel on every render and restart the animation mid-breath.
    @State private var screen: PracticeScreen?

    init(skillID: String) {
        self.skillID = skillID
        _screen = State(initialValue: PracticeRegistry.screen(for: skillID))
    }

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [Color("Warm Cream"), Color("Light Cream")]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                Spacer()
                if let screen {
                    screen.content
                } else {
                    unbuiltPlaceholder
                }
                Spacer()
                doneButton
            }
            .padding(30)
        }
        .overlay {
            if let skillID = router.repeatCompletionSkillID {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    PracticeRepeatCompletionView(skillID: skillID)
                        .frame(maxWidth: 300)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            }
        }
//        .animation(.easeOut(duration: 0.2), value: router.repeatCompletionSkillID)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let session = screen?.session
                session?.onComplete = { [weak session, skillID, gardenStore, router] in
                    session?.stop()
                    handlePracticeCompletion(skillID: skillID, gardenStore: gardenStore, router: router)
                }
                session?.start()
        }
        .onDisappear {
            screen?.session.stop()
        }
    }

    private var skillName: String {
        ContentRepository.skill(id: skillID)?.name ?? ""
    }

    /// Close abandons the practice: no plant, straight back. Deliberately
    /// different from Done — the plant is the reward for actually doing it.
    private var header: some View {
        ZStack {
            Text(skillName.uppercased())
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.brown)

            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.systemBrown))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.white.opacity(0.6)))
                }
                Spacer()
            }
        }
    }

    private var doneButton: some View {
        if gardenStore.gardenState.onboardingDone == true {
            Button("Done") {
                PracticeService.complete(skillID: skillID, in: gardenStore)
                screen?.session.stop()
                handlePracticeCompletion(skillID: skillID, gardenStore: gardenStore, router: router)
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.darkBrown)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
        }
        else{
            Button("Done") {
                PracticeService.complete(skillID: skillID, in: gardenStore)
                router.popToRoot()
                router.selectedTab = .garden
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.darkBrown)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
        }
    }

    /// A skill whose practice hasn't been built yet. Says so plainly instead of
    /// crashing, and still lets you walk the rest of the flow while you build.
    private var unbuiltPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "hammer")
                .font(.system(size: 40))
            Text("This practice isn't built yet.")
                .font(.system(size: 17, design: .rounded))
        }
        .foregroundStyle(.brown)
    }
    
    private func handlePracticeCompletion(
        skillID: String,
        gardenStore: GardenStore,
        router: Router
    ) {
        let isFirstTime = PracticeService.complete(skillID: skillID, in: gardenStore)
        if isFirstTime {
            router.showFirstCompletion(skillID: skillID)
        } else {
            router.showRepeatCompletion(skillID: skillID)
        }
    }
}

