//
//  ActivationView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct ActivationView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: the add
    /// field and the time wheel both write back. It borrows rather than owns, so
    /// the host is still the one holding the session.
    @Bindable var viewModel: ActivationViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: ActivationStep.numerals,
                currentIndex: viewModel.currentStep.rawValue,
                completed: viewModel.completedIndices,
                onTap: viewModel.revisit
            )

            ScrollView(showsIndicators: false) {
                stepContent
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .animation(.easeInOut(duration: 0.28), value: viewModel.currentStep)
        .animation(.snappy, value: viewModel.activities)
        .animation(.snappy, value: viewModel.chosenActivityID)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .mood:     moodStep
        case .list:     listStep
        case .pick:     pickStep
        case .schedule: scheduleStep
        }
    }

    /// Asked before anything else, and that ordering is the point — thinking
    /// about things you used to enjoy lifts your mood on its own, so a baseline
    /// taken after step 2 would be measuring step 2.
    private var moodStep: some View {
        VStack(spacing: 18) {
            heading("How's your mood right now?",
                    detail: "Before we start. There's no right answer, and a low one isn't a failure.")

            IntensityScale(
                label: "Right now",
                value: viewModel.moodNow,
                lowLabel: "Flat",
                highLabel: "Good",
                onSelect: viewModel.rateMood
            )

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveMood,
                          action: viewModel.commitMood)
        }
    }

    private var listStep: some View {
        VStack(spacing: 18) {
            heading("What used to feel good?",
                    detail: "Things that used to bring some satisfaction, even if they don't sound appealing today.")

            if !viewModel.isActivityListFull {
                addActivityRow
            }

            activityList

            primaryButton("Continue",
                          isEnabled: viewModel.canLeaveList,
                          action: viewModel.commitList)
        }
    }

    private var pickStep: some View {
        VStack(spacing: 18) {
            heading("Pick one for today",
                    detail: "The smallest one you could actually finish. Not the most worthwhile one.")

            VStack(spacing: 8) {
                ForEach(viewModel.activities) { activity in
                    choiceRow(activity)
                }
            }

            primaryButton("Continue",
                          isEnabled: viewModel.canLeavePick,
                          action: viewModel.commitChoice)
        }
    }

    /// The whole point of the skill in one screen: a specific thing at a
    /// specific time, decided now rather than when you feel like it.
    private var scheduleStep: some View {
        VStack(spacing: 18) {
            heading("Give it a time",
                    detail: "Like an appointment. Motivation tends to arrive after you start, not before.")

            if let activity = viewModel.chosenActivity {
                Text(activity.text)
                    .font(.system(size: 15, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.darkBrown)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background { card }
            }

            DatePicker("",
                       selection: $viewModel.scheduledTime,
                       displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Text("Becube won't remind you yet — write it down somewhere it'll find you.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            primaryButton("Finish", isEnabled: true, action: viewModel.finish)
        }
    }

    // MARK: - Pieces

    private var addActivityRow: some View {
        HStack(spacing: 10) {
            TextField("e.g. Walk to the warung", text: $viewModel.draftActivity)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .submitLabel(.done)
                .onSubmit { viewModel.addActivity() }
                .padding(12)
                .background { card }

            Button {
                viewModel.addActivity()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.darkBrown))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canAddActivity)
            .opacity(viewModel.canAddActivity ? 1 : 0.35)
        }
    }

    private var activityList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.activities) { activity in
                HStack(spacing: 10) {
                    Text(activity.text)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Color.darkBrown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // Without this a wrapping line gets truncated in an HStack.
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        viewModel.removeActivity(activity)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background { card }
            }
        }
    }

    private func choiceRow(_ activity: Activity) -> some View {
        let isChosen = viewModel.chosenActivityID == activity.id

        return Button {
            viewModel.choose(activity)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isChosen ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isChosen ? Color.darkBrown : Color.darkBrown.opacity(0.4))

                Text(activity.text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            // Styling belongs on the label, not the Button: hung off the Button
            // it still draws, but the hit region stays the size of the glyphs.
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(isChosen ? 1 : 0.7))
                    .overlay {
                        if isChosen {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.darkBrown, lineWidth: 1.5)
                        }
                    }
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func heading(_ title: LocalizedStringKey, detail: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(title)
                // Jua has a single weight, so no `.bold()`.
                .font(.custom("Jua-Regular", size: 24))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.darkBrown)

            Text(detail)
                .font(.system(size: 15, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
    }

    private func primaryButton(
        _ title: LocalizedStringKey,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .frame(height: 46)
                .background(Color.darkBrown)
                .clipShape(Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
    }
}

#Preview {
    ActivationView(viewModel: ActivationViewModel(skillID: "behavioral_activation"))
}
