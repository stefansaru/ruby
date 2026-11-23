# Objectives

Written 2026-11-24. **v1 means "must be true before the first Google Play
release"**; v2 is what follows. Targets marked *(proposed)* are the agent's
starting figures and wait for an owner ruling; they are goals, not counts of
what exists. Do not read a current count from this page: the case packs in
`lib/data/` and the test run are the source for what exists.

## v1 goals

| Id | Goal | Measure | Carried by |
|---|---|---|---|
| G1 | Every shipped case is fair | 100% of shipped cases have exactly one solution and are solved by the logical solver without guessing, checked by tests on every run | STRAT-MIS-002, GEN register |
| G2 | Clues cannot be misread | Every clue type has one documented machine meaning, a wording template and an in-game preview; zero open wording defects at release | STRAT-VAL-001, APP-UX-002, APP-UX-003 |
| G3 | Enough to play | Case packs for all five tiers across all twelve settings; about 200 cases at launch *(proposed)* | STRAT-OBJ-001 |
| G4 | Honest money | Banner plus opt-in rewarded video only; no ad can start while a case is open | STRAT-MIS-001, APP-ADS-003 |
| G5 | Notes that hold a deduction | Per-suspect candidate marks and crosses, with undo | APP-GAM-003 |
| G6 | Hints that teach | Each hint names the technique and the square | APP-GAM-006 |
| G7 | Quality gates | `flutter analyze` clean and `flutter test` green on every commit; generator dry-run reproduces the shipped packs | STRAT-OBJ-002, PROC-CMT-001 |
| G8 | Readable on a small phone | Every object and token readable on a 360 dp wide screen; no meaning carried by colour alone | APP-ACC-001, APP-AST-002 |
| G9 | Cleared to publish | Name and trademark check done; content rating and ad settings confirmed for the murder theme | STRAT-RSK-001, STRAT-RSK-003 |

## v2 directions

| Id | Direction | Note |
|---|---|---|
| H1 | Daily case with streak and spoiler-free share card | [DailyCase.md](../features/DailyCase.md); proven by three competitors |
| H2 | Languages: Spanish, Dutch, German first | The markets where the books sold out; clue text is templated so that this is translation work, not engineering |
| H3 | One-time remove-ads purchase | Demand shown by the paid-only competitors |
| H4 | Later rules | Two-time-slot timeline, testimony revealed as you place, weapon and motive, locked doors, conditional clues |
| H5 | iOS release | The scaffold includes iOS; nothing is tested there yet |
| H6 | Website page on jini.solutions | Kept in TODO.md by owner decision 2026-11-24 |
