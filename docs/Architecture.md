# Architecture

Dated 2026-11-24. What exists is the engine, the generator, the data and the tools.
The app layers (screens, services, ads) are designed in the feature docs and listed
in [../TODO.md](../TODO.md); this file gains a section for each when it is built.

## 1. The rule

**The engine decides, the view draws.** Everything that can be right or wrong about a
case (may this person stand here, is this clue true, is the case solved, what is the
next step) is answered in `lib/engine/`, in pure Dart. Screens will ask it and draw
the answer.

Reason: the rules can then be tested without a device, reused by the generator and
the tools, and never drift between "what the game checks" and "what the solver
proved". `test/architecture_test.dart` enforces the layers on the import lines
(GEN-023).

```
tool/  ──reads args and files──▶  lib/gen/  ──▶  lib/engine/
                                     │
                                     ▼
                                 lib/data/  (settings; generated packs)
app (not built)  ───────────────▶  lib/engine/, lib/data/     never lib/gen/
```

## 2. Engine (`lib/engine/`)

| File | Job |
|---|---|
| `model.dart` | `CaseDef` and its parts (grids, areas, object kinds, squares, doors and windows, people). The placement rules: `conflict`, `canOccupy`, `touching`, `murdererIn`, and `check`, which judges a full placement. |
| `clue.dart` | Every clue type. `CellTest` is a question about one square; `Clue` is a statement or general clue. `holds` is the single meaning of a clue (GEN-004). |
| `atoms.dart` | Splits clues into simple pieces both solvers use: about one person, about two people, counts, "others in my area", and a generic fallback. Adds the victim rule and the no-touch rule as pieces. |
| `exact_solver.dart` | `solveExact`: every placement that fits, up to a limit. Used to prove a case has one solution. |
| `logic_solver.dart` | `solveLogic`: solves by named techniques, records each step, takes the player's placements. Grades difficulty and is the source of hints. |
| `wording.dart` | The English sentence for each clue and rule. |
| `case_text.dart` | The case text format. `parseCase` is also the validator (GEN-006); `writeCase` is its inverse (GEN-009). |

Two solvers, on purpose. The exact one answers "is there exactly one answer?" by
search and explains nothing. The logic one answers "can a person get there without
guessing, and how hard is it?" and never searches blindly. A case ships only when
both agree (see [Levels.md](Levels.md)).

The exact solver always places the person with the fewest squares left, removes
squares from the others as it goes, and stops a branch as soon as a count cannot come
out right. Before that change (same day) it checked most clues only at the end and
the expert pack took over twenty minutes; see [Performance.md](Performance.md).

## 3. Generator (`lib/gen/`)

Offline only. No `dart:io`, no Flutter, never imported by the app. It lives in `lib/`
and not in `tool/` because `flutter test --coverage` only measures `package:` files
(the lesson is pushy's).

| File | Job |
|---|---|
| `gen_config.dart` | `Tier` (the technique range of each tier) and `GenConfig` (one slot); refuses nonsense by field name (GEN-017). |
| `gen_scene.dart` | Draws grids, areas, objects, doors and windows, the cast, and a placement that obeys the rules. Titles. |
| `gen_clues.dart` | Lists every true statement the tier allows (`Family`), adds statements until one placement is left, drops what is not needed. |
| `gen_case.dart` | `generateCase`: the gates in order and the funnel (GEN-018). |
| `gen_check.dart` | `checkShipped`: the honest check of a stored case, starting from its text. |
| `gen_campaign.dart` | The slots of every pack: shape, setting, seed. |
| `gen_render.dart` | Writes a pack as Dart source. |

One `Random`, seeded per slot, is the only source of chance (GEN-016).

## 4. Data (`lib/data/`)

- `settings.dart`: hand-written. The places, their areas and objects.
- `cases_<tier>.dart`: generated, with a header that says so. Never edited by hand.
- `cases.dart`: hand-written index of the packs.

Packs are source and not assets so that a broken case fails to compile or fails a
test instead of failing on a phone.

## 5. Tools (`tool/`)

| Command | What it does |
|---|---|
| `dart run tool/generate_cases.dart` | Builds every pack. `--only=<tier>`, `--dry-run` (compare with disk, exit 1 on a difference), `--probe=N` (first N slots, funnel only), `--verbose` (a line per slot). |
| `dart run tool/check_cases.dart` | Runs `checkShipped` over every stored case; exit 1 on any failure. |
| `dart run tool/show_case.dart <tier> <n> [--answer]` | Prints a case as a player reads it; with `--answer`, the answer and the solver's steps. |
| `dart run tool/bench_gen.dart [--n=N]` | Times a sample of slots from every tier. |
| `py -3 tool/write_sprite_prompts.py` | Writes the art prompts; see [Art.md](Art.md). |
| `./doctor.sh`, `.\doctor.ps1` | The commit gates, in order. |

## 6. How a case is made

1. `campaign(tier)` lists the slots.
2. For each slot `generateCase` draws a scene and a placement, chooses clues, and
   passes the draw through the gates. A draw that fails any gate is thrown away and
   the next is drawn from the same `Random`.
3. `renderPack` writes the accepted cases to `lib/data/cases_<tier>.dart`.
4. The tests and `check_cases.dart` read the stored text back and check it again
   without trusting the generator.

## 7. Planned app layers (not built)

Following amethyst and day_ok: `lib/screens/`, `lib/widgets/`, `lib/theme/`,
`lib/services/` (settings, progress, hint coins, consent, rewarded ads, ad health),
`lib/helpers/`. State with `ChangeNotifier`/`ValueNotifier`, storage behind a
key-value interface, no state-management package. This section is a plan, not a
description; it is replaced when the code exists.
