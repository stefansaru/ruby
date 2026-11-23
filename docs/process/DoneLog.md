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

To be added when true: the first commit and push (with the commit hash).

Not built in this round, and not claimed: any playable screen, notes, hint
text or hint screen, coins, ads, the daily case, art, sound, translations, the
store release and the website page. They are in `TODO.md`.
