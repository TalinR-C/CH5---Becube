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

    /// Completion has to happen once, whichever gets there first: the practice
    /// ending on its own or the user tapping Done. A reference box rather than a
    /// `Bool` state so the session's callback can close it without capturing the view.
    @State private var gate = CompletionGate()

    private final class CompletionGate { var isClosed = false }

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
            if let completion = router.repeatCompletion {
                ZStack {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    PracticeRepeatCompletionView(skillID: completion.skillID, logID: completion.logID)
                        .frame(maxWidth: 300)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            }
        }
//        .animation(.easeOut(duration: 0.2), value: router.repeatCompletion)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let session = screen?.session
            session?.onComplete = { [weak session, gate, skillID, gardenStore, router] in
                session?.stop()
                Self.completePractice(gate: gate, skillID: skillID, store: gardenStore, router: router)
            }
            session?.start()
        }
        .onDisappear {
            screen?.session.stop()
            // The card belongs to this screen: leaving by any route (including a
            // swipe back) takes it with us, so it can't reappear over the next practice.
            router.repeatCompletion = nil
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

    /// Read through the existential, so `@Observable` still tracks whatever
    /// stored state the session computes it from.
    private var isDoneEnabled: Bool {
        screen?.session.isDoneEnabled ?? true
    }

    private var doneButton: some View {
        Button("Done") {
            screen?.session.stop()
            Self.completePractice(gate: gate, skillID: skillID, store: gardenStore, router: router)
        }
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.darkBrown)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
        .disabled(!isDoneEnabled)
        .opacity(isDoneEnabled ? 1 : 0.35)
        .animation(.easeInOut(duration: 0.2), value: isDoneEnabled)
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
    
    /// The single completion path: writes the one log, grants the plant, then
    /// shows whichever celebration fits. Ignored if completion already happened,
    /// so a Done tap on the same practice can't log it twice.
    ///
    /// `static` so the session's callback can call it without capturing the view.
    private static func completePractice(
        gate: CompletionGate,
        skillID: String,
        store: GardenStore,
        router: Router
    ) {
        guard !gate.isClosed else { return }
        gate.isClosed = true

        let completion = PracticeService.complete(skillID: skillID, in: store)

        // Onboarding skips the celebration screens — the tour ends in the Garden,
        // where the first plant is waiting.
        guard store.gardenState.onboardingDone else {
            router.popToRoot()
            router.selectedTab = .garden
            return
        }

        if completion.isFirstUnlock {
            router.showFirstCompletion(skillID: completion.skillID, logID: completion.logID)
        } else {
            router.showRepeatCompletion(completion)
        }
    }
}

