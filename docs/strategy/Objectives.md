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
| G3 | Enough to play | Case packs for all five tiers across all twelve settings; 436 cases are built (2026-11-25; about 200 was proposed on 2026-11-24); the launch figure is the owner's to set | STRAT-OBJ-001 |
| G4 | Honest money | No ads of any kind (owner ruling 2026-11-25). The tutorial and easy packs are free and fully playable; one one-time purchase unlocks the rest *(model recommended, price not yet confirmed by the owner; [Monetisation.md](Monetisation.md))* | STRAT-MIS-001, APP-PAY-001, APP-PAY-002, APP-PAY-003 |
| G5 | Notes that hold a deduction | Per-suspect candidate marks and crosses, with undo | APP-GAM-003 |
| G6 | Hints that teach | Each hint names the technique and the square | APP-GAM-006 |
| G7 | Quality gates | `flutter analyze` clean and `flutter test` green on every commit; generator dry-run reproduces the shipped packs | STRAT-OBJ-002, PROC-CMT-001 |
| G8 | Readable on a small phone | Every object and token readable on a 360 dp wide screen; no meaning carried by colour alone | APP-ACC-001, APP-AST-002 |
| G9 | Cleared to publish | Name and trademark check done; content rating confirmed for the murder theme | STRAT-RSK-001, STRAT-RSK-003 |

## v2 directions

| Id | Direction | Note |
|---|---|---|
| H1 | Daily case with streak and spoiler-free share card | [DailyCase.md](../features/DailyCase.md); proven by three competitors |
| H2 | Languages: Spanish, Dutch, German first | The markets where the books sold out; clue text is templated so that this is translation work, not engineering |
| H3 | Paid extras, if any | The one-time unlock moved to v1 (G4) on 2026-11-25 and there are no ads to remove. Open: whether extra statements or hints are ever sold, and whether future packs are included in the one purchase ([Monetisation.md](Monetisation.md)) |
| H4 | Later rules | Two-time-slot timeline, testimony revealed as you place, weapon and motive, locked doors, conditional clues |
| H5 | iOS release | The scaffold includes iOS; nothing is tested there yet |
| H6 | Website page on jini.solutions | Kept in TODO.md by owner decision 2026-11-24 |
