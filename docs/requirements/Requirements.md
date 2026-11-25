# Requirements

Entry point to the requirements of Detective Sudoku (codename ruby). Written 2026-11-24.
The format follows amethyst (`docs/requirements/Requirements.md` there) and, for the
machine-checked register, pushy (`docs/requirements/GEN-nnn.md` there).

## Layers

| Layer | Prefix | Says | Lives in |
|---|---|---|---|
| Strategy | `STRAT-{MIS,VAL,OBJ,MKT,RSK}-nnn` | What the product must be, derived from mission, values, objectives, market and risks | [strategy_requirements/](strategy_requirements/) |
| App | `APP-{GAM,UX,PAY,ADS,PRV,ACC,L10N,AST,QAL}-nnn` | What the player-facing app must do | [app_requirements/](app_requirements/) |
| Process | `PROC-{CMT,TST,DOC,REL,CNT}-nnn` | How the work is done | [process_requirements/](process_requirements/) |
| Engine and generator | `GEN-nnn` | What the rules engine, solver and generator must guarantee; **each id is cited by a test and a test checks that** | [gen/](gen/README.md) |

Strategy requirements are carried by app, process and GEN requirements; each file links
to the ones that carry it. There is no normative layer (GDPR, store policy, WCAG as
numbered sources) yet; it is added when the legal and release work starts, and until
then an APP file's NORM line reads "derived".

## The GEN register

The rules of the game as the engine enforces them, the solver's guarantees (one
solution, no guessing, difficulty by technique) and the generator's gates are **not**
in the APP layer. They are in the [GEN register](gen/README.md), one file per id,
and `test/requirements_test.dart` fails when an id is not cited by a test or a test
cites an id that does not exist. Where a file on this page says "GEN register", that
is where the detail is. GEN ids are listed in the register's own index, not here,
so that there is one list to keep right.

## Naming

- Ids are unique across the project and **never reused or renumbered**. A retired id
  stays, marked ⛔, with a line saying what replaced it.
- Three digits, zero-padded. One file per id, named after the id.
- Other docs cite a requirement by id.

## Status

| Mark | Meaning |
|---|---|
| ✅ Done | Every acceptance criterion is met and, where it can be, tested |
| ⚠️ Partial | In force or partly built; the file says what is missing |
| ❌ Pending | Not built |
| ⛔ Retired | No longer a requirement; the file says why and what replaced it |

A status is a claim about the repository today. A requirement is not ✅ because the
code was written; it is ✅ when its criteria are checked. This register was written
on 2026-11-24, before the app existed, so nearly everything is ❌ and that is correct.
The statuses were revised the same day once the engine, the generator, the packs and
the tests existed: what a test or tool proves is ✅, what is built on the engine side
and waits for a screen is ⚠️, and each such file says what is still open.

## File format

App and process files: Tags, Status, then *Requirement*, *Why*, *Acceptance
Criteria* (checkboxes), *Implementation*, *Related Tests*, *Related Requirements*,
*Related Docs*. Strategy files: front matter (tags, status, strategic sources), then
*Intent*, *Requirement*, *Strategic Sources*, *Acceptance Criteria*, *Evidence*,
*Related Requirements*.

## Index

### Strategy

| Id | Title | Tags | Status |
|---|---|---|---|
| [STRAT-MIS-001](strategy_requirements/STRAT-MIS-001.md) | Fair Monetisation Without Ads: Free to Try, One Purchase | Mission, Monetisation, PlayerRespect | ❌ Pending |
| [STRAT-MIS-002](strategy_requirements/STRAT-MIS-002.md) | Every Case Is Fair | Mission, Fairness, Generator | ✅ Done |
| [STRAT-VAL-001](strategy_requirements/STRAT-VAL-001.md) | One Exact Meaning per Clue | Values, Clarity, Wording | ⚠️ Partial |
| [STRAT-VAL-002](strategy_requirements/STRAT-VAL-002.md) | Respect: No Gates, No Nags | Values, PlayerRespect | ❌ Pending |
| [STRAT-VAL-003](strategy_requirements/STRAT-VAL-003.md) | Our Own Work | Values, Originality, Legal | ⚠️ Partial |
| [STRAT-VAL-004](strategy_requirements/STRAT-VAL-004.md) | Simple Words, Simple Places | Values, Clarity, Content | ⚠️ Partial |
| [STRAT-OBJ-001](strategy_requirements/STRAT-OBJ-001.md) | Launch Content Floor | Objectives, Content | ⚠️ Partial |
| [STRAT-OBJ-002](strategy_requirements/STRAT-OBJ-002.md) | Gates Green Before Anything Ships | Objectives, Quality | ⚠️ Partial |
| [STRAT-MKT-001](strategy_requirements/STRAT-MKT-001.md) | Position: The Detective Puzzle That Plays Fair | Market, Positioning | ❌ Pending |
| [STRAT-MKT-002](strategy_requirements/STRAT-MKT-002.md) | Languages Where the Books Sold | Market, Localisation | ❌ Pending |
| [STRAT-RSK-001](strategy_requirements/STRAT-RSK-001.md) | Name and Trademark Check Before Listing | Risk, Legal, Release | ❌ Pending |
| [STRAT-RSK-002](strategy_requirements/STRAT-RSK-002.md) | Art Review Gate | Risk, Art | ❌ Pending |
| [STRAT-RSK-003](strategy_requirements/STRAT-RSK-003.md) | Bloodless Theme, Truthful Rating | Risk, Legal, Content | ❌ Pending |

### App — Gameplay

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-GAM-001](app_requirements/gam/APP-GAM-001.md) | Placing and Removing People | Gameplay, Core | ⚠️ Partial |
| [APP-GAM-002](app_requirements/gam/APP-GAM-002.md) | Accusation and Win Check | Gameplay, Core | ⚠️ Partial |
| [APP-GAM-003](app_requirements/gam/APP-GAM-003.md) | Notes per Suspect | Gameplay, Notes | ❌ Pending |
| [APP-GAM-004](app_requirements/gam/APP-GAM-004.md) | Auto-Eliminate Toggle | Gameplay, Notes, Settings | ❌ Pending |
| [APP-GAM-005](app_requirements/gam/APP-GAM-005.md) | Undo, Redo and Restart | Gameplay | ❌ Pending |
| [APP-GAM-006](app_requirements/gam/APP-GAM-006.md) | Hint Ladder | Gameplay, Hints | ⚠️ Partial |
| [APP-GAM-007](app_requirements/gam/APP-GAM-007.md) | Hint Economy: One Coin Balance | Gameplay, Hints, Monetisation, Persistence | ⛔ Retired |
| [APP-GAM-008](app_requirements/gam/APP-GAM-008.md) | Tutorial | Gameplay, Onboarding | ❌ Pending |
| [APP-GAM-009](app_requirements/gam/APP-GAM-009.md) | Case Selection Without Gates | Gameplay, Progression | ❌ Pending |
| [APP-GAM-010](app_requirements/gam/APP-GAM-010.md) | Daily Case | Gameplay, Retention, v2 | ❌ Pending |
| [APP-GAM-011](app_requirements/gam/APP-GAM-011.md) | Mistakes Are Not Punished | Gameplay, Tone | ❌ Pending |
| [APP-GAM-012](app_requirements/gam/APP-GAM-012.md) | Save and Resume a Case | Gameplay, Persistence | ❌ Pending |

### App — User experience

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-UX-001](app_requirements/ux/APP-UX-001.md) | Lettered Columns and Numbered Rows | UX, Clarity, Grid | ⚠️ Partial |
| [APP-UX-002](app_requirements/ux/APP-UX-002.md) | Clue Preview | UX, Clarity | ❌ Pending |
| [APP-UX-003](app_requirements/ux/APP-UX-003.md) | Plain, Exact Clue Wording | UX, Clarity, Content | ⚠️ Partial |
| [APP-UX-004](app_requirements/ux/APP-UX-004.md) | Glossary and Object Guide in the Game | UX, Clarity, Help | ❌ Pending |
| [APP-UX-005](app_requirements/ux/APP-UX-005.md) | A Line of Story | UX, Tone, Content | ❌ Pending |
| [APP-UX-006](app_requirements/ux/APP-UX-006.md) | No Early Rating Prompt | UX, PlayerRespect | ❌ Pending |
| [APP-UX-007](app_requirements/ux/APP-UX-007.md) | A Clue List You Can Work With | UX, Gameplay | ❌ Pending |

### App — Purchase

Written 2026-11-25. The model is recommended and the owner has not yet confirmed the price
([Monetisation.md](../strategy/Monetisation.md)).

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-PAY-001](app_requirements/pay/APP-PAY-001.md) | One Purchase Unlocks Everything; No Ads Anywhere | Pay, Monetisation, PlayerRespect | ❌ Pending |
| [APP-PAY-002](app_requirements/pay/APP-PAY-002.md) | The Free Part Is Fully Playable | Pay, Monetisation, PlayerRespect, Progression | ❌ Pending |
| [APP-PAY-003](app_requirements/pay/APP-PAY-003.md) | Restorable, Works Offline, Price Before the Gate | Pay, Monetisation, Persistence, Honesty | ❌ Pending |

### App — Advertising (retired 2026-11-25)

The game carries no ads (owner ruling 2026-11-25). Replaced by APP-PAY-001.

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-ADS-001](app_requirements/ads/APP-ADS-001.md) | Banner | Ads, Monetisation | ⛔ Retired |
| [APP-ADS-002](app_requirements/ads/APP-ADS-002.md) | Rewarded Video for Hint Coins | Ads, Monetisation, Hints | ⛔ Retired |
| [APP-ADS-003](app_requirements/ads/APP-ADS-003.md) | Ads Never Interrupt, Never Touch Audio | Ads, PlayerRespect | ⛔ Retired |
| [APP-ADS-004](app_requirements/ads/APP-ADS-004.md) | Ad Unit Ids: Test by Default, Production at Release | Ads, Build, Security | ⛔ Retired |

### App — Privacy

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-PRV-001](app_requirements/prv/APP-PRV-001.md) | Consent Before the Ad SDK | Privacy, Ads, Legal | ⛔ Retired |
| [APP-PRV-002](app_requirements/prv/APP-PRV-002.md) | No Account, Data Stays on the Device | Privacy | ❌ Pending |
| [APP-PRV-003](app_requirements/prv/APP-PRV-003.md) | Privacy Policy and Age Handling | Privacy, Legal, Release | ❌ Pending |

### App — Accessibility

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-ACC-001](app_requirements/acc/APP-ACC-001.md) | Nothing by Colour Alone | Accessibility, Grid | ❌ Pending |
| [APP-ACC-002](app_requirements/acc/APP-ACC-002.md) | Tap Targets and Text Size | Accessibility, Layout | ❌ Pending |
| [APP-ACC-003](app_requirements/acc/APP-ACC-003.md) | Screen Reader Labels | Accessibility | ❌ Pending |

### App — Localisation

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-L10N-001](app_requirements/l10n/APP-L10N-001.md) | All Player Text from Templates | Localisation, Engine, Content | ⚠️ Partial |
| [APP-L10N-002](app_requirements/l10n/APP-L10N-002.md) | English First, A Language Only When Complete | Localisation, Release | ❌ Pending |

### App — Assets and art

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-AST-001](app_requirements/ast/APP-AST-001.md) | Pixel Art from Tracked Sheets and Prompts | Assets, Art, Pipeline | ❌ Pending |
| [APP-AST-002](app_requirements/ast/APP-AST-002.md) | Objects Read at a Glance | Assets, Art, Clarity | ❌ Pending |
| [APP-AST-003](app_requirements/ast/APP-AST-003.md) | Portraits Are Cosmetic Unless a Clue Says Otherwise | Assets, Art, Rules | ❌ Pending |

### App — Quality

| Id | Title | Tags | Status |
|---|---|---|---|
| [APP-QAL-001](app_requirements/qal/APP-QAL-001.md) | Analyzer Clean, Tests Green | Quality, Process | ⚠️ Partial |
| [APP-QAL-002](app_requirements/qal/APP-QAL-002.md) | Every Shipped Case Is Replayed by Tests | Quality, Content, Fairness | ✅ Done |
| [APP-QAL-003](app_requirements/qal/APP-QAL-003.md) | Plays Offline | Quality, Platform | ❌ Pending |
| [APP-QAL-004](app_requirements/qal/APP-QAL-004.md) | A Hint Arrives Quickly | Quality, Performance | ❌ Pending |

### Process

| Id | Title | Tags | Status |
|---|---|---|---|
| [PROC-CMT-001](process_requirements/PROC-CMT-001.md) | Commit Gates | Process, Commit, Quality | ⚠️ Partial |
| [PROC-CMT-002](process_requirements/PROC-CMT-002.md) | Commit Only When Asked; Never the Working Folders | Process, Commit | ⚠️ Partial |
| [PROC-TST-001](process_requirements/PROC-TST-001.md) | Requirements Are Cited by Tests | Process, Testing, Traceability | ✅ Done |
| [PROC-TST-002](process_requirements/PROC-TST-002.md) | Manual Test Plan Before a Release | Process, Testing, Release | ❌ Pending |
| [PROC-DOC-001](process_requirements/PROC-DOC-001.md) | Rules Carry Their Reason and Date | Process, Documentation | ⚠️ Partial |
| [PROC-DOC-002](process_requirements/PROC-DOC-002.md) | One Source for Every Number | Process, Documentation | ⚠️ Partial |
| [PROC-REL-001](process_requirements/PROC-REL-001.md) | Release Builds | Process, Release, Build | ❌ Pending |
| [PROC-REL-002](process_requirements/PROC-REL-002.md) | The Listing Says Only What Is True | Process, Release, Marketing, Honesty | ❌ Pending |
| [PROC-CNT-001](process_requirements/PROC-CNT-001.md) | Cases Are Generated, Seeded and Never Hand-Edited | Process, Content, Generator | ⚠️ Partial |
| [PROC-CNT-002](process_requirements/PROC-CNT-002.md) | No Third-Party Content | Process, Content, Legal | ⚠️ Partial |
| [PROC-CNT-003](process_requirements/PROC-CNT-003.md) | Player-Facing Words Are Proposed First | Process, Content, UX | ❌ Pending |

### Engine and generator

See [gen/README.md](gen/README.md).
