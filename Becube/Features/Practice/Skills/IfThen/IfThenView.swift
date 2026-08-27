//
//  IfThenView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct IfThenView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: both
    /// halves of the draft write back. It borrows rather than owns, so the host
    /// is still the one holding the session.
    @Bindable var viewModel: IfThenViewModel

    var body: some View {
        VStack(spacing: 22) {
            LetterProgress(
                letters: IfThenStep.numerals,
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
        .animation(.snappy, value: viewModel.plans)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .plan:     planStep
        case .rehearse: rehearseStep
        }
    }

    private var planStep: some View {
        VStack(spacing: 18) {
            heading("Make the plan now",
                    detail: "One situation you know is coming, and one thing you'll do when it does.")

            if !viewModel.isPlanListFull {
                draftCard
            }

            planList

            primaryButton("Continue",
                          isEnabled: viewModel.canLeavePlan,
                          action: viewModel.commitPlans)
        }
    }

    /// The "If" and "then I will" are printed, not typed.
    ///
    /// That sentence shape is the skill — Gollwitzer's finding is about the
    /// specific if-then structure, not about having a good intention — so it
    /// lives in the chrome where it can't be edited away.
    private var draftCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            halfField(prefix: "If",
                      placeholder: "I walk past the shop on Jalan Raya",
                      text: $viewModel.draftTrigger)

            halfField(prefix: "then I will",
                      placeholder: "keep walking and call Dita",
                      text: $viewModel.draftResponse)

            suggestionRow

            HStack {
                Spacer()
                Button(action: viewModel.addPlan) {
                    Label("Add plan", systemImage: "plus")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 42)
                        .background(Capsule().fill(Color.darkBrown))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canAddPlan)
                .opacity(viewModel.canAddPlan ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.2), value: viewModel.canAddPlan)
            }
        }
        .padding(16)
        .background { card }
    }

    private func halfField(
        prefix: LocalizedStringKey,
        placeholder: LocalizedStringKey,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(prefix)
                .font(.custom("Jua-Regular", size: 16))
                .foregroundStyle(Color.darkBrown)

            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .lineLimit(1...3)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.darkBrown.opacity(0.2), lineWidth: 1)
                        }
                }
        }
    }

    /// The other fifteen skills, one tap away from becoming the "then" half.
    ///
    /// This is the only screen in the app where the toolbox points at itself —
    /// a plan that reads "then I will do Box Breathing" turns sixteen separate
    /// practices into one that knows about the others.
    private var suggestionRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Or use a skill you already know")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.suggestions) { skill in
                        Button {
                            viewModel.suggest(skill)
                        } label: {
                            Text(skill.name)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.darkBrown)
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .frame(height: 34)
                                .background {
                                    Capsule().stroke(Color.darkBrown.opacity(0.35), lineWidth: 1)
                                }
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var planList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.plans) { plan in
                HStack(alignment: .top, spacing: 10) {
                    Text(plan.sentence)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Color.darkBrown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // Without this a wrapping line gets truncated in an HStack.
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        viewModel.removePlan(plan)
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

    /// Reading them back is the mechanism, not a summary screen.
    ///
    /// The link between situation and response is built by rehearsing the
    /// sentence — a plan typed once and never re-read is only half the skill.
    private var rehearseStep: some View {
        VStack(spacing: 18) {
            heading("Say each one to yourself",
                    detail: "Twice, if you can. Repeating it is what makes the situation bring the plan to mind.")

            VStack(spacing: 12) {
                ForEach(viewModel.plans) { plan in
                    CommentBox(bulge: 6, contentPadding: 18) {
                        Text(plan.sentence)
                            .font(.custom("Jua-Regular", size: 17))
                            .foregroundStyle(Color.darkBrown)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: 240)
                    }
                }
            }

            primaryButton("Finish", isEnabled: true, action: viewModel.finish)
        }
    }

    // MARK: - Pieces

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
    IfThenView(viewModel: IfThenViewModel(skillID: "if_then_planning"))
}
