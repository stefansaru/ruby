# Documentation map

Each file has one job. When two files disagree, the one named here as the owner of
the subject is right and the other is fixed.

Conventions (2026-11-24, taken from pushy and amethyst because they kept those
projects' docs true):

- Every rule carries its reason and its date.
- Present tense means now. What is no longer true moves to [History.md](History.md).
- Counts that live in code (how many cases, how many tests) are stated only where they
  are a decision or a measurement, with a date; elsewhere the doc names the file that
  holds them. (Revised 2026-11-25: the rule now says what is done.)
- Outstanding work is only in [../TODO.md](../TODO.md); known faults only in
  [../OpenIssues.md](../OpenIssues.md).

## The game

| File | Owns |
|---|---|
| [GameRules.md](GameRules.md) | The rules, the words with one meaning, every clue and case rule. The authority on behaviour. |
| [Techniques.md](Techniques.md) | The solving techniques, in order of difficulty; what each hint will explain. |
| [Settings.md](Settings.md) | The places, their areas and objects, and the naming rule. |
| [Levels.md](Levels.md) | The case text format, what a shipped case must satisfy, tiers, packs. |
| [Glossary.md](Glossary.md) | Terms used in docs and code. |

## The code

| File | Owns |
|---|---|
| [Architecture.md](Architecture.md) | Layers, files, tools, how a case flows from generator to pack. |
| [Testing.md](Testing.md) | The gates and the reason for each. |
| [testing/Tests.md](testing/Tests.md) | Inventory of the test files. |
| [testing/ManualTestPlan.md](testing/ManualTestPlan.md) | Checks a person runs. |
| [testing/Exploratory.md](testing/Exploratory.md) | The rules explored by tests that draw their own inputs, the second witness, planted bugs, and charters for exploring by hand. |
| [Performance.md](Performance.md) | Measured generator and solver times. |
| [Art.md](Art.md) | What must be drawn, sheet formats, the art pipeline. |
| [architecture/ads/Ads.md](architecture/ads/Ads.md) | Retired 2026-11-25: the game carries no ads. Kept as a pointer. |

## Features (designs; see TODO for what is built)

| File | Owns |
|---|---|
| [features/Modes.md](features/Modes.md) | Detective and cat mode: the research, what changes (only words), the draft copy, what is open. |
| [features/Screens.md](features/Screens.md) | Landscape, tablets, Google TV and other sizes: what works, what does not, what each needs. |
| [features/Hints.md](features/Hints.md) | Hints (free): what the draft does, the hint ladder, extra statements. |
| [features/Notes.md](features/Notes.md) | Per-suspect notes and marks. |
| [features/DailyCase.md](features/DailyCase.md) | The shared daily case. |

## Why and for whom

| File | Owns |
|---|---|
| [strategy/VisionMissionValues.md](strategy/VisionMissionValues.md) | Vision, mission, values. |
| [strategy/Objectives.md](strategy/Objectives.md) | Measurable goals. |
| [strategy/MarketResearch.md](strategy/MarketResearch.md) | The genre, the twelve competitors, prices and models of rivals, sources. |
| [strategy/TargetAudience.md](strategy/TargetAudience.md) | Who plays, how, and what they pay for. |
| [strategy/PainPointsAndConcepts.md](strategy/PainPointsAndConcepts.md) | What players complain about and our answer to each. |
| [strategy/RiskAnalysis.md](strategy/RiskAnalysis.md) | Risks and mitigations. |
| [strategy/Monetisation.md](strategy/Monetisation.md) | No ads; free to try, one purchase; price, comparables, what we will not do. |
| [marketing/](marketing/) | Launch campaign, reel scripts, store listing draft. |

## Requirements and process

| File | Owns |
|---|---|
| [requirements/Requirements.md](requirements/Requirements.md) | Entry point: strategy, app and process requirements, one file per id. |
| [requirements/gen/README.md](requirements/gen/README.md) | The machine-checked engine and generator register (GEN ids). |
| [process/CommitChecklist.md](process/CommitChecklist.md) | What to run before a commit. |
| [process/DoneLog.md](process/DoneLog.md) | Finished work, by date. |
| [History.md](History.md) | Decisions reversed and things no longer true. |
