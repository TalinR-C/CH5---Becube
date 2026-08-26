//
//  ProblemSolvingViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 26/08/26.
//

import Foundation

/// The five steps, in the only order they work in.
///
/// Unlike TIPP this is not a pick-one: you cannot weigh options you have not
/// listed, and you cannot pick one you have not weighed. The walk is strictly
/// forward, which is why the strip across the top is numbered rather than
/// lettered — this skill has no acronym to spell.
///
/// `tryIt` rather than `try`: `try` is a keyword.
enum ProblemSolvingStep: Int, CaseIterable, Identifiable {
    case define, list, weigh, pick, tryIt

    var id: Int { rawValue }

    /// What `LetterProgress` draws. It takes whatever strings it is given, so
    /// an acronym-less skill gets its step numbers and the component stays put.
    static let numerals = ["1", "2", "3", "4", "5"]
}

/// One idea, and the single upside and downside it was weighed by.
///
/// A struct in an array on the ViewModel rather than its own `@Observable`:
/// mutating an element is then what publishes the change, and there is only
/// ever one owner of the list.
struct SolutionOption: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var upside: String = ""
    var downside: String = ""
}

@MainActor
@Observable
final class ProblemSolvingViewModel: PracticeSession {

    let skillID: String
    var onComplete: (() -> Void)?

    // MARK: - Limits
    //
    // Every cap here is doing therapeutic work, not just guarding a text field.
    // "One clear sentence" is the instruction for step 1, and a box that will
    // not hold a paragraph teaches it better than a label asking nicely.

    static let problemCharLimit = 120
    static let optionCharLimit = 70
    static let weighNoteCharLimit = 70

    /// Enough to get past the obvious answer, few enough to still weigh them
    /// all. Beyond five, step 3 turns into a form.
    static let maxOptions = 5

    /// "List every possible solution" with one entry is not the skill — it is
    /// the thing they were already stuck on.
    static let minOptions = 2

    /// Matched to the reflection box, so the plan handed onto the log doesn't
    /// get silently clipped the moment the user edits it there.
    static let journalCharLimit = 200

    // MARK: - State

    private(set) var currentStep: ProblemSolvingStep = .define

    /// Steps already walked. Never emptied by revisiting one — going back to
    /// reread the problem does not undo having defined it.
    private(set) var completed: Set<ProblemSolvingStep> = []

    /// Reassigning inside `didSet` re-enters the setter here. On a plain stored
    /// property Swift suppresses that; under `@Observable` the property is
    /// rewritten into a computed one, so the write goes back through the setter
    /// and fires `didSet` again. Hence the guard: it must only write when it
    /// genuinely has something to trim, or it recurses until the stack gives out.
    var problem: String = "" {
        didSet {
            guard problem.count > Self.problemCharLimit else { return }
            problem = String(problem.prefix(Self.problemCharLimit))
        }
    }

    private(set) var options: [SolutionOption] = []

    /// The add-field on step 2. Held here rather than in the view so returning
    /// to the step doesn't lose a half-typed idea.
    var draftOption: String = "" {
        // Guarded for the same reason as `problem` above.
        didSet {
            guard draftOption.count > Self.optionCharLimit else { return }
            draftOption = String(draftOption.prefix(Self.optionCharLimit))
        }
    }

    /// Which option step 3 is currently showing. Weighing is paged one at a
    /// time: four options weighed on one screen is eight text fields at once.
    private(set) var weighIndex = 0

    private(set) var chosenOptionID: UUID?

    init(skillID: String) {
        self.skillID = skillID
    }

    // MARK: - Derived

    /// What `LetterProgress` needs — it draws positions, not steps.
    var completedIndices: Set<Int> { Set(completed.map(\.rawValue)) }

    var canLeaveDefine: Bool { !problem.isTrimmedEmpty }

    var canAddOption: Bool {
        !draftOption.isTrimmedEmpty && options.count < Self.maxOptions
    }

    var isOptionListFull: Bool { options.count >= Self.maxOptions }

    var canLeaveList: Bool { options.count >= Self.minOptions }

    var currentOption: SolutionOption? {
        options.indices.contains(weighIndex) ? options[weighIndex] : nil
    }

    var isLastOption: Bool { weighIndex >= options.count - 1 }

    var chosenOption: SolutionOption? {
        options.first { $0.id == chosenOptionID }
    }

    /// Bound by the view. The getter and setter both go through `weighIndex`,
    /// so the array itself stays `private(set)` and there is exactly one way to
    /// write to an option.
    var currentUpside: String {
        get { currentOption?.upside ?? "" }
        set { updateCurrentOption { $0.upside = Self.capped(newValue, to: Self.weighNoteCharLimit) } }
    }

    var currentDownside: String {
        get { currentOption?.downside ?? "" }
        set { updateCurrentOption { $0.downside = Self.capped(newValue, to: Self.weighNoteCharLimit) } }
    }

    /// A screen you opened and walked away from is not a practice. Defining the
    /// problem is the smallest thing that counts as having done this one.
    var isDoneEnabled: Bool { !completed.isEmpty }

    /// Handed to the host at completion and written onto the log this practice
    /// earns, so the plan is already sitting in the reflection box when the
    /// user comes back to say how it went.
    ///
    /// Capped rather than composed to fit: the pieces are already short enough
    /// that the cap should never bite, and truncating is better than handing
    /// Reflect something it will clip without saying so.
    var journalDraft: String? {
        let problem = self.problem.trimmed
        guard !problem.isEmpty else { return nil }

        var draft = "Problem: \(problem)"
        if let chosen = chosenOption?.text.trimmed, !chosen.isEmpty {
            draft += "\nTrying: \(chosen)"
        }
        return Self.capped(draft, to: Self.journalCharLimit)
    }

    // MARK: - PracticeSession

    /// Nothing runs on its own here — no clock, no animation to pace. The host
    /// still calls both, so they stay and stay empty on purpose.
    func start() {}

    func stop() {}

    // MARK: - Intent

    /// Tapping a number. Only backwards, and only to somewhere already visited —
    /// jumping ahead would skip the step the next one is built on.
    func revisit(_ index: Int) {
        guard let step = ProblemSolvingStep(rawValue: index),
              step != currentStep,
              completed.contains(step)
        else { return }

        currentStep = step
        clampWeighIndex()
    }

    func commitProblem() {
        guard canLeaveDefine else { return }
        advance(to: .list)
    }

    func addOption() {
        guard canAddOption else { return }
        options.append(SolutionOption(text: draftOption.trimmed))
        draftOption = ""
    }

    /// Removing an idea has to take everything that pointed at it with it —
    /// otherwise step 4 keeps a selection the user can no longer see.
    func removeOption(_ option: SolutionOption) {
        options.removeAll { $0.id == option.id }
        if chosenOptionID == option.id { chosenOptionID = nil }
        clampWeighIndex()
    }

    func commitOptions() {
        guard canLeaveList else { return }
        weighIndex = 0
        advance(to: .weigh)
    }

    /// Step 3's "next" — through the options, then on to picking one.
    func nextOption() {
        guard currentStep == .weigh else { return }

        if isLastOption {
            advance(to: .pick)
        } else {
            weighIndex += 1
        }
    }

    func previousOption() {
        guard currentStep == .weigh, weighIndex > 0 else { return }
        weighIndex -= 1
    }

    /// Tapping an option on step 4. Tapping the chosen one again clears it —
    /// changing your mind should not need a separate control.
    func choose(_ option: SolutionOption) {
        chosenOptionID = (chosenOptionID == option.id) ? nil : option.id
    }

    func commitChoice() {
        guard chosenOptionID != nil else { return }
        advance(to: .tryIt)
    }

    /// The practice's natural end. Step 5 — checking how it went — cannot
    /// happen in this sitting, so what ends here is the commitment to try;
    /// the checking is the reflection they come back and write.
    func finish() {
        stop()
        completed.insert(.tryIt)
        onComplete?()
    }

    // MARK: - Flow

    private func advance(to step: ProblemSolvingStep) {
        completed.insert(currentStep)
        currentStep = step
    }

    private func updateCurrentOption(_ change: (inout SolutionOption) -> Void) {
        guard options.indices.contains(weighIndex) else { return }
        change(&options[weighIndex])
    }

    /// Going back to step 2 and deleting ideas can leave step 3 pointing past
    /// the end of the list.
    private func clampWeighIndex() {
        weighIndex = min(weighIndex, max(options.count - 1, 0))
    }

    private static func capped(_ text: String, to limit: Int) -> String {
        text.count > limit ? String(text.prefix(limit)) : text
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isTrimmedEmpty: Bool { trimmed.isEmpty }
}
