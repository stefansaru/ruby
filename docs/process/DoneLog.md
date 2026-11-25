# Done Log

Finished work, newest first. An item closed in `TODO.md` moves here with its
number, the date and, once committed, the commit. `TODO.md` holds only
outstanding work.

## Round 1 — foundations (2026-11-24)

Scope set by the owner on 2026-11-24: documentation, Flutter scaffold, the
pure-Dart engine and solver, the generator, a first set of generated case
packs, and tests. No playable UI and no ad code in this round.

Done on 2026-11-24:

- **Engine** (`lib/engine/`, pure Dart): the case model; clue types with one
  `holds` each; the case text format, whose parser is the validator; clue
  pieces shared by both solvers (`atoms.dart`); the exact solver (one solution
  or not); the logic solver (named techniques, recorded steps, accepts the
  player's placements); English clue wording.
- **Generator** (`lib/gen/`): scenes from twelve settings, clue choice until
  one placement is left, dropping of unneeded clues, six gates with a funnel,
  the campaign of pinned slots, pack rendering, and the honest check of a
  stored case (`gen_check.dart`).
- **Tools** (`tool/`): `generate_cases.dart` (with `--dry-run`, `--only`,
  `--probe`, `--verbose`), `check_cases.dart`, `show_case.dart`,
  `bench_gen.dart`, `write_sprite_prompts.py`.
- **Case packs** (`lib/data/cases_<tier>.dart`): tutorial, easy, normal, hard
  and expert, including two-grid, non-square, cut-corner, one-liar and
  no-touch cases. The dry run reproduces them byte for byte and every case
  passes the sweep. Counts live in `lib/gen/gen_campaign.dart`.
- **Tests** (`test/`, inventory in `docs/testing/Tests.md`): engine, generator,
  every shipped case, the layer rules, and the GEN register kept in step with
  the tests. Analyzer clean, suite green.
- **Docs:** game rules, techniques, levels, settings, glossary, art needs and
  draft sprite prompts, manual test plan, test inventory, and the GEN register
  (`docs/requirements/gen/`).

- Research: the source book's rules, glossary, FAQ and puzzle anatomy read
  from the owner's photos (kept in the ignored `input/` folder); twelve
  competing Play listings; the conventions of pushy, amethyst and day_ok.
- Owner decisions recorded: round scope; cosy bloodless murder tone; v1 rule
  set (core, multiple grids, irregular grids, new rules); pixel art through
  the pushy pipeline; website page deferred to TODO.
- Flutter project created (`com.jinisolutions.ruby`; Android, iOS, web);
  `input/` and `output/` ignored.
- Strategy docs: vision, mission and values; objectives; market research;
  target audience; pain points and concepts; risk analysis; monetisation.
- Feature designs (not built): hints, notes, daily case; advertising design.
- Marketing drafts: launch campaign, reel scripts, store listing.
- Process: commit checklist, this log.
- Requirements register: strategy, app and process layers, one file per id.

The first commit and push: 703bdc8, "Detective Sudoku round 1: docs, engine, generator,
case packs". The later rounds are not committed (2026-11-25).

Not built in this round, and not claimed: any playable screen, notes, hint
text or hint screen, coins, ads, the daily case, art, sound, translations, the
store release and the website page. They are in `TODO.md`.

## After the first play on a phone (2026-11-24)

- TODO 6 closed: each area lists the objects that belong in it; the generator and
  the shipped-case check keep to the list (GEN-029).
- The victim is always a V, listed last (GEN-030), and placed last by the solver
  and the hints (GEN-031).
- Easy cases need clue and single only; last in line moved to normal (GEN-032).
  All five packs regenerated.
- Playable draft: crosses on the row and column of a placed person; the hint says
  who and why before it gives the square.

## After the second play on a phone (2026-11-25)

- Train lamp replaced by a suitcase; titles from the setting (GEN-033); no unused doors or
  windows (GEN-034); extra statements in the case format and the generator (GEN-035);
  100 cases each in tutorial, easy, normal and hard; all packs regenerated.
- Statements as a checklist with tick and cross (GEN-036); "+" for one more statement;
  placed cards greyed; next person selected and scrolled to; tap on a placed person lifts
  them; hint card shorter and closable; area names on the grid.
- Cases made on request (GEN-037) with a button under each pack.
- Detective and cat mode as a wording switch; "How to play" sheet.
- Progress, mode and opened extras saved on the device (TODO 19, the saving part).
- Owner ruling: no ads. TODO items 27, 29 to 34 and 36 (coins, consent, banner, rewarded
  video, ad health, ad ids, audio check, AdMob account) are dropped, not done. Monetisation rewritten.
- Research recorded: non-murder puzzle books (docs/features/Modes.md); prices and audience
  (docs/strategy/Monetisation.md, TargetAudience.md, MarketResearch.md).

## The audit (2026-11-25)

- Docs audit: 15 groups of findings applied (stale "not built" statements, the full
  list of what `checkShipped` refuses, requirement statuses, "Covered by" lines, the
  sprite tool and Art.md learning the suitcase).
- Architecture audit: play decisions moved into `CaseSession`; shared rules given one
  home; `Tier` and `usedOpenings` moved to the engine; the architecture test rewritten
  as allowlists; `readHeader` for the case list.
- Code review: grid clipping on wide and short screens, taps after solving, liar and
  two-grid hints, the random button, parser values that can never be true, tool
  arguments, saved numbers that make no sense, starting without storage.
- Tests: 145 to 208; line coverage 95.6% to 99.96%.

## Exploratory tests (2026-11-25)

- A second witness for the rules (`test/support/oracle.dart`) and 35 exploratory tests in
  `test/explore/`: engine against oracle, solvers against the slow search, mirrors, a
  random player, sentences against clues, damaged text, random taps (GEN-038 to 041).
- `tool/plant_bugs.py`: 32 planted bugs, all caught after three gaps were closed.
- docs/testing/Exploratory.md: the rules explored, how to run deep, charters for a person.
