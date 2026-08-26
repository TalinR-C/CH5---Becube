# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Becube is an iOS SwiftUI app (single Xcode target, no SPM/CocoaPods dependencies) that teaches coping
skills through a forest/garden metaphor: users unlock forest "areas," learn coping skills ("plants"),
practice them via guided mini-exercises, and reflect on outcomes in a calendar log. Bundle ID
`com.talin.Becube`, Swift 5.0, deployment target set in `Becube.xcodeproj` (`IPHONEOS_DEPLOYMENT_TARGET`).

The codebase is early-stage: many files are placeholder stubs (a header comment + `// TODO: implement`)
that establish the intended architecture but have no logic yet. Check a file's actual contents before
assuming it's implemented — several `ViewModel`/`Service` files across `Domain/`, `Services/`, and
`Features/Practice/` are currently empty scaffolding.

## Build, run, lint

There is no CLI test target and no linter config in this repo — verification is done by building/running
in Xcode or via `xcodebuild`.

```bash
# List targets/schemes
xcodebuild -list -project Becube.xcodeproj

# Build for the simulator
xcodebuild -project Becube.xcodeproj -scheme Becube -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build and run: open in Xcode and Cmd+R (simplest path; no test target exists to drive from CLI)
open Becube.xcodeproj
```

The `Becube` scheme/target is the only target — there's no separate widget extension target yet, despite
the `Becube/Widget/` folder (it currently builds into the main app target as a stub).

## Architecture

SwiftUI + SwiftData, MVVM, organized by layer first and then by feature:

```
Becube/
  App/          App entry point, root tab view, router
  Data/         SwiftData store + static JSON content loading
  Domain/       Pure-Swift business logic (no SwiftUI/SwiftData imports)
  Models/       Codable content models + @Model persistence models
  Features/     One folder per screen/flow, each with View + @Observable ViewModel
  Services/     Platform-facing services (e.g. notifications)
  Widget/       WidgetKit extension code (stub)
```

**Persistence (SwiftData).** `GardenState` and `Log` are the two `@Model` classes (in
`Models/Persistence/`), registered in the `Schema` in `BecubeApp.swift`. `GardenStore`
(`Data/GardenStore.swift`) is an `@Observable` class that owns the single `GardenState` (fetches or
creates it on init) and the full `Log` history, and is injected app-wide via `.environment(gardenStore)`
in `BecubeApp.swift`. Feature ViewModels take a `GardenStore` in their initializer rather than touching
`ModelContext` directly — the exception is `ForestMapViewModel`, which currently takes a `ModelContext`
directly and does its own fetch/insert of `GardenState` (a pattern in flux; prefer the `GardenStore`
approach for new code, matching `GardenViewModel`/`ShelfListViewModel`).

**Static content (JSON, not user data).** `CopingSkill` (a "plant"/skill) and `ForestArea` are immutable
`Codable` structs decoded from bundled JSON in `Data/Resources/` (`areas.json`, `skills_en.json`,
`skills_id.json` for localized skill content). Two parallel loading paths currently exist:
- `ContentRepository` (`Data/ContentRepository.swift`) — static `let skills`/`let areas` properties,
  decoded once at process start via `decodeSkill`/`decodeArea`. This is the one feature ViewModels
  generally use (`ContentRepository.skills`, `ContentRepository.areas`).
- `Bundle.decode(_:from:)` (`Utils.swift`) — a generic `Bundle` extension used ad hoc by some ViewModels
  (e.g. `ForestMapViewModel`) to decode the same JSON files independently.

Both are legitimate but redundant; when touching this area, prefer consolidating on one rather than
adding a third path. Both `fatalError` on missing/malformed JSON — that's intentional (content files are
bundled and considered a build invariant, not user-facing failure).

**Domain layer.** `Domain/` holds (or is meant to hold, per the stub headers) pure-Swift business rules
decoupled from SwiftUI/SwiftData: `Progression` (unlock rules), `PracticeService` (record practice,
grant a plant), `ReflectionService`, `ToolkitService`, `SkillStats`. As of now these are stubs; unlock
logic currently lives directly in `ForestMapViewModel.unlockFirstAreaIfNeeded()`/`unlocked(_:)` — when
implementing `Progression`, that logic is the intended home for it.

**Features.** Each feature folder pairs a SwiftUI `View` with an `@Observable` `ViewModel` that's
constructed by the parent view and passed in (no DI container). Tabs wired in `App/RootView.swift`:
Shelf, Garden, Forest (`GardenStore` is read via `@Environment(GardenStore.self)`). Notable feature
structure:
- `Features/Forest/` — map of unlockable areas (`ForestMapView`/`ForestMapViewModel`) drilling into an
  area's skill list (`ForestAreaView`/`ForestAreaViewModel`).
- `Features/Practice/` — intended plugin-style structure for guided mini-exercises: `PracticeRegistry`
  maps a practice kind to a view, `PracticeSession` is a shared protocol every practice ViewModel adopts,
  `PracticeHostView` provides shared chrome (close/skip/completion). Concrete skills live under
  `Practice/Skills/<Name>/` (`BodyScan`, `BoxBreathing`, `FiveSenses`), each with its own View + ViewModel
  — currently all stubs.
- `Features/Learn/` — the "how/when/why" explainer shown before practicing a skill. `LearnViewModel` is
  the most fully-implemented ViewModel in the repo and a good reference for the intended style: paged via
  a `CaseIterable` enum (`Page`), content pulled from `CopingSkill.info[key]` by key, `onJumpToPractice`
  closure to hand off into `Features/Practice`.
- `Features/Reflect/` — calendar/journal log view over `Log` history; `Components/` has calendar and
  scheduling subviews.
- `Features/Shelf/` — grid of unlocked skills (`unlockedPlantsID` on `GardenState`), with search
  filtering in `ShelfListViewModel`.
- `Features/Garden/` — visualizes unlocked plants; currently mostly scratch/debug UI
  (`GardenView.swift` has test buttons wired directly to `GardenViewModel`, not final UI).

**Localization.** `Localizable.xcstrings` (String Catalog) plus a localized JSON content pair
(`skills_en.json` / `skills_id.json`) for skill copy — two separate localization mechanisms to be aware
of when adding user-facing strings vs. skill content.

## Conventions observed in this codebase

- ViewModels are `@Observable` (not `ObservableObject`/`@Published`) — this is a modern-SwiftData-era
  (iOS 17+/26 style) codebase; don't introduce Combine-based state.
- Views own their ViewModel via `@State private var viewModel: SomeViewModel?`, initialized in `.task`
  once environment values (e.g. `ModelContext`) are available — see `ForestMapView` — or take an
  already-constructed ViewModel via `init` from the parent — see `GardenView`, `ShelfListView`.
- `Domain/` and other "pure Swift" layers are explicitly meant to avoid `import SwiftUI`/`import
  SwiftData` per their header comments — keep that boundary when implementing the stubs.
