//
//  WritingView.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 27/08/26.
//

import SwiftUI

struct WritingView: View {

    /// `@Bindable` rather than the plain `let` the timed practices use: both the
    /// entry and the closing note write back. It borrows rather than owns, so
    /// the host is still the one holding the session.
    @Bindable var viewModel: WritingViewModel

    /// The keyboard covers most of this screen by design — it is a writing
    /// screen. This is how it gets dismissed, since a `TextEditor` has no scroll
    /// view of its own to swipe down.
    @FocusState private var isWriting: Bool

    var body: some View {
        Group {
            switch viewModel.stage {
            case .setup:   setupStage
            case .writing: writingStage
            case .closing: closingStage
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.stage)
    }

    // MARK: - Setup

    /// Everything the user needs to decide before a word is typed, including
    /// the two things they would be right to be annoyed about learning later:
    /// this can feel worse before it feels better, and none of it is saved.
    private var setupStage: some View {
        VStack(spacing: 22) {
            heading("How long will you write?",
                    detail: "Set it and forget it. Keep the pen moving until the time is up.")

            HStack(spacing: 10) {
                ForEach(WritingViewModel.lengths, id: \.self) { minutes in
                    lengthChip(minutes)
                }
            }

            VStack(spacing: 10) {
                note(icon: "lock", text: "Nothing you write here is saved. Afterwards you'll be asked for one line about it — that part is kept.")
                note(icon: "exclamationmark.triangle", text: "Writing about something painful can feel more intense before it feels better. Stop if it becomes too much, and talk to someone you trust.")
            }

            primaryButton("Start writing",
                          isEnabled: viewModel.chosenMinutes != nil,
                          action: viewModel.begin)
        }
    }

    private func lengthChip(_ minutes: Int) -> some View {
        let isSelected = viewModel.chosenMinutes == minutes

        return Button {
            viewModel.choose(minutes: minutes)
        } label: {
            VStack(spacing: 1) {
                Text("\(minutes)")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Text("min")
                    .font(.system(size: 11, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : Color.darkBrown)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            // Styling belongs on the label, not the Button: hung off the Button
            // it still draws, but the hit region stays the size of the glyphs.
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.darkBrown : .white.opacity(0.85))
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Writing

    /// A bar, not a ring, and no number at all.
    ///
    /// A closing circle or a ticking countdown in the corner of your eye is the
    /// wrong companion for this — it turns writing into waiting. The bar answers
    /// "roughly how far in am I" without ever demanding to be read.
    private var writingStage: some View {
        VStack(spacing: 14) {
            progressBar

            TextEditor(text: $viewModel.entry)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .scrollContentBackground(.hidden)
                .focused($isWriting)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.85))
                }
                .frame(minHeight: 280)
                .overlay(alignment: .topLeading) {
                    // TextEditor has no placeholder of its own.
                    if viewModel.entry.isEmpty {
                        Text("Whatever's weighing on you. Grammar doesn't matter, and neither does whether it makes sense.")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }

            if viewModel.canFinishEarly {
                secondaryButton("Finish writing", action: viewModel.finishWriting)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isWriting = false }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
        }
        .onAppear { isWriting = true }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.darkBrown.opacity(0.15))

                Capsule()
                    .fill(Color.darkBrown.opacity(0.55))
                    .frame(width: geometry.size.width * viewModel.progress)
            }
        }
        .frame(height: 4)
        // Matched to the ViewModel's tick so the bar glides rather than stepping.
        .animation(.linear(duration: 0.5), value: viewModel.progress)
    }

    // MARK: - Closing

    private var closingStage: some View {
        VStack(spacing: 20) {
            heading("Put it down",
                    detail: "Don't reread it. That part comes later, if at all.")

            CommentBox(bulge: 6, contentPadding: 20) {
                Text("One line about having written it — not about what you wrote.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Color.darkBrown)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 240)
            }

            writingField(
                "e.g. Heavier than I expected, but I got it out.",
                text: $viewModel.note,
                limit: WritingViewModel.noteCharLimit,
                lines: 1...3
            )

            primaryButton("Finish", isEnabled: true, action: viewModel.finish)
        }
    }

    // MARK: - Pieces

    private func note(icon: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(.secondary)
                // Without this a wrapping line gets truncated inside an HStack.
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background { card }
    }

    private func writingField(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        limit: Int,
        lines: ClosedRange<Int>
    ) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .lineLimit(lines)
                .padding(12)
                .background { card }

            if !text.wrappedValue.isEmpty {
                Text("\(text.wrappedValue.count)/\(limit)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
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

    private func secondaryButton(_ title: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.darkBrown)
                .padding(.horizontal, 24)
                .frame(height: 46)
                .background {
                    Capsule()
                        .fill(.white)
                        .overlay { Capsule().stroke(Color.darkBrown.opacity(0.4), lineWidth: 1) }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.85))
    }
}

#Preview {
    WritingView(viewModel: WritingViewModel(skillID: "expressive_writing"))
}
