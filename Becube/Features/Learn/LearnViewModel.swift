//
//  LearnViewModel.swift
//  Becube
//
//  Created by Talin Russo-Christoffelsz on 13/08/26.
//
//  to navigate and move every learning sheets

import Foundation

@Observable ///letting the changes can be implemented on all of the views
class LearnViewModel {
    
    ///Page state, controlling each page in learn view
    ///CaseIterable means wrapping enum in array so it's easier to count the indexes of enum's element
    enum Page: Int, CaseIterable, Hashable {
        case how, when, why
        
        ///A computed property that change the ENUM into Strings (for JSON file)
        var infoKey: String {
            switch self {
            case .how: return "how"
            case .when: return "when"
            case .why: return "why"
            }
        }
        
        /// title for each current Page, resolved from `Localizable.xcstrings`
        /// (keys `learn.page.<how|when|why>.title`) so it follows the app's language.
        /// `Bundle.localizedString(forKey:)`, not `String(localized:)` interpolation —
        /// see the note on `CopingSkill.localizedName`.
        var title: String {
            Bundle.main.localizedString(forKey: "learn.page.\(infoKey).title", value: nil, table: nil)
        }
    }
    
    let skillID: String ///The ID for the coping skills
    var currentPage: Page = .how ///Default page
    var skill: CopingSkill?

    let gardenStore: GardenStore

    /// Adding closure that will handle a function later
    var onJumpToPractice: (() -> Void)?

    /// Initializer (a constructor to build viewmodel once the app starts running and inserting skill ID)
    init(skillID: String, gardenStore: GardenStore) {
        self.skillID = skillID
        self.gardenStore = gardenStore
    }
    
    ///fetching the JSON data file through content repository
    func loadSkill() {
        skill = ContentRepository.skills.first(where: { $0.id == skillID })
        ///$0 means checking all skills one by one
    }
    
    ///compare the current page with Page.allCases.last (.why) so to decide next or practice button
    var isLastPage: Bool {
        currentPage == Page.allCases.last
    }
    
    var isFirstPage: Bool {
        currentPage == Page.allCases.first
    }

    ///Control the page's searching and prevent array out of bounds
    func goToNextPage() {
        guard let currentIndex = Page.allCases.firstIndex(of: currentPage) else { return }
        let nextIndex = currentIndex + 1
        guard nextIndex < Page.allCases.count else { return }
        currentPage = Page.allCases[nextIndex]
        grantPlantIfFinished()
    }

    // MARK: - Progression

    /// Whether this skill's plant is already growing in the garden.
    var isLearned: Bool {
        gardenStore.hasUnlockedPlant(id: skillID)
    }

    /// The skill counts as learned once the user has reached the final page,
    /// meaning every page of the explainer has been shown. Granting here rather
    /// than on the closing button means a user who reads the whole thing keeps
    /// the plant even if they are not ready to practice yet.
    ///
    /// Jumping straight to practice deliberately does *not* grant it — that
    /// skips the learning, and rewarding the practice run is `PracticeService`'s
    /// job once the practice flow exists.
    private func grantPlantIfFinished() {
        guard isLastPage else { return }
        gardenStore.unlockPlant(id: skillID)
    }
    
    func goToPreviousPage() {
        guard let currentIndex = Page.allCases.firstIndex(of: currentPage) else { return }
        let previousIndex = currentIndex - 1
        guard previousIndex >= 0 else { return }
        currentPage = Page.allCases[previousIndex]
    }
    
    ///searching for currentpage's index
    var currentPageIndex: Int {
        Page.allCases.firstIndex(of: currentPage) ?? 0
    }

    ///fetching the skill's name
    var skillName: String {
        skill?.localizedName.uppercased() ?? ""
    }

    ///error handling
    var currentPageText: String {
        skill?.localizedInfo(currentPage.infoKey) ?? "Content not available."
    }
}


