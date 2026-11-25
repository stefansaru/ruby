# Architecture

Dated 2026-11-24, revised 2026-11-25. What exists is the engine, the generator, the
data, the tools and a playable draft of the app (section 7). What is not built is
listed in [../TODO.md](../TODO.md); this file gains a section for each part when it is.

## 1. The rule

**The engine decides, the view draws.** Everything that can be right or wrong about a
case (may this person stand here, is this clue true, is the case solved, what is the
next step) is answered in `lib/engine/`, in pure Dart. Screens ask it and draw
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
app  ────────────────────────────▶  lib/engine/, lib/data/
app, one file only (random_case)  ─▶  lib/gen/
```

## 2. Engine (`lib/engine/`)

| File | Job |
|---|---|
| `model.dart` | `CaseDef` and its parts (grids, areas, object kinds, squares, doors and windows, people). The placement rules: `conflict`, `canOccupy`, `touching`, `murdererIn`, and `check`, which judges a full placement. |
| `clue.dart` | Every clue type. `CellTest` is a question about one square; `Clue` is a statement or general clue. `holds` is the single meaning of a clue (GEN-004). |
| `atoms.dart` | Splits clues into simple pieces both solvers use: about one person, about two people, counts, "others in my area", and a generic fallback. Adds the victim rule and the no-touch rule as pieces. |
| `exact_solver.dart` | `solveExact`: every placement that fits, up to a limit. Used to prove a case has one solution. |
| `logic_solver.dart` | `solveLogic`: solves by named techniques, records each step, takes the player's placements. Grades difficulty and is the source of hints. |
| `wording.dart` | The English sentence for each clue and rule. `Mode`, `describeVictim`, `describeSolved`, `howToPlay`, `describeStep`, `describeHint`. |
| `case_text.dart` | The case text format. `parseCase` is also the validator (GEN-006); `writeCase` is its inverse (GEN-009). |
| `tier.dart` | `Tier`: the technique range of each tier; in the engine since 2026-11-25 so the app can name a tier without importing the generator. |
| `openings.dart` | `usedOpenings`: which doors and windows the clues need (GEN-034); exhaustive over every clue and test type. |

`model.dart` and `clue.dart` import each other. It is the only import cycle in `lib/`
and it is accepted (2026-11-25): a case holds clues and a clue reads a case.

Two solvers, on purpose. The exact one answers "is there exactly one answer?" by
search and explains nothing. The logic one answers "can a person get there without
guessing, and how hard is it?" and never searches blindly. A case ships only when
both agree (see [Levels.md](Levels.md)).

The exact solver always places the person with the fewest squares left, removes
squares from the others as it goes, and stops a branch as soon as a count cannot come
out right. Before that change (same day) it checked most clues only at the end and
the expert pack took over twenty minutes; see [Performance.md](Performance.md).

## 3. Generator (`lib/gen/`)

No `dart:io`, no Flutter. Until 2026-11-25 the app never imported it; since then one
service, `lib/services/random_case.dart`, calls it to make a case on request, and
`test/architecture_test.dart` allows that file and no other. It lives in `lib/`
and not in `tool/` because `flutter test --coverage` only measures `package:` files
(the lesson is pushy's).

| File | Job |
|---|---|
| `gen_config.dart` | `GenConfig` (one slot); refuses nonsense by field name (GEN-017). Re-exports `Tier` from `lib/engine/tier.dart`, where it has lived since 2026-11-25. |
| `gen_scene.dart` | Draws grids, areas, objects, doors and windows, the cast, and a placement that obeys the rules. Titles. |
| `gen_clues.dart` | Lists every true statement the tier allows (`Family`), adds statements until one placement is left, drops what is not needed. |
| `gen_case.dart` | `generateCase`: the gates in order and the funnel (GEN-018). |
| `gen_check.dart` | `checkShipped`: the honest check of a stored case, starting from its text. `misplacedObject`: an object in an area that does not list it. |
| `gen_campaign.dart` | The slots of every pack: shape, setting, seed. |
| `gen_render.dart` | Writes a pack as Dart source. |

One `Random`, seeded per slot and made in `generateCase`, is the only source of chance
in a case. `randomConfig` in `gen_campaign.dart` makes a second one from the same seed
to pick the shape, setting and title of a case made on request (GEN-016, GEN-037).

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
| `py -3 tool/plant_bugs.py [suite]` | Plants one deliberate bug at a time in `lib/` and reports which tests notice; see [testing/Exploratory.md](testing/Exploratory.md). Slow; not a gate. |
| `./doctor.sh`, `.\doctor.ps1` | The commit gates, in order. |

## 6. How a case is made

1. `campaign(tier)` lists the slots.
2. For each slot `generateCase` draws a scene and a placement, chooses clues, and
   passes the draw through the gates. A draw that fails any gate is thrown away and
   the next is drawn from the same `Random`.
3. `renderPack` writes the accepted cases to `lib/data/cases_<tier>.dart`.
4. The tests and `check_cases.dart` read the stored text back and check it again
   without trusting the generator.

## 7. The playable draft (2026-11-24, revised 2026-11-25)

| File | Job |
|---|---|
| `lib/engine/session.dart` | `CaseSession`: the player's placements, who is selected, what a tap does (`tap` returns placed, lifted, refused or ignored), who is next, clashes, the squares to cross out, the statements a card shows and the mark of each (open, met, broken), solved, and what a hint says and why (worked out once per board). Pure Dart, so the screen decides nothing. |
| `lib/screens/home_screen.dart` | A tab per tier, a row per case with a green tick when solved, a "Generate a random case" button under each list, a menu for the mode and "How to play". |
| `lib/screens/case_screen.dart` | One case: grids, a closable message card, character cards whose statements are a checklist (tick, cross, "+" for one more). Placed cards are greyed and the next person is selected and scrolled to. |
| `lib/widgets/case_grid.dart` | Draws one grid with placeholder shapes, the area names on wall-coloured tabs hanging from the walls, and a cross on squares ruled out by a placed person; reports taps. `GridGeometry` maps squares to pixels. |
| `lib/widgets/clue_text.dart` | Draws `**key words**` bold. |
| `lib/theme/palette.dart` | Placeholder colours. |
| `lib/services/progress.dart` | Solved cases, the mode and opened extras, saved through a store. |
| `lib/services/store.dart` | `KeyValueStore`: text by key. `PrefsStore` on the device, `MemoryStore` in tests. |
| `lib/services/random_case.dart` | Makes a case of a tier on the device, off the UI thread, and runs `checkShipped` on it; gives up with an error after 40 seeds. The only app file that imports the generator. |

## 8. Not built

Not built (2026-11-25): `lib/helpers/`, a settings screen service, the purchase
service. The screens, widgets, theme and the services of section 7 exist.

## 9. What the audit of 2026-11-25 changed, and why

- **The session owns the play decisions.** Selection, the meaning of a tap, the next
  person and the statements on a card were in `case_screen.dart`; they are in
  `CaseSession` now, and every sentence a player reads is in `wording.dart` (notices
  included). *Why:* the one architectural rule; and the same victim-last order was
  written in three places.
- **One home for rules used in several places:** `CaseDef.capacity`, `isFull`, `clash`,
  `placeLabel`, `colLabel`, `GridDef.label`, `isRandomId`. *Why:* the capacity sum was
  written four times and the column letter six.
- **`readHeader`** (`case_text.dart`) reads id, title, setting, sizes and cast size for
  the case list without checking the case. *Why:* the list parsed and verified a whole
  case for every row it built.
- **`Tier` and `usedOpenings` live in the engine.** *Why:* the app named tiers by string
  because the enum sat in the generator; and the check of a shipped case used the
  generator's own function to check the generator.
- **The architecture test is a list of allowed imports** (GEN-023).
- **Accepted, not changed:** `Progress` and `RandomCases.inBackground` are static and
  reached directly by the screens; tests reset them in `setUp`. `model.dart` and
  `clue.dart` import each other. Hints run on the UI thread (23 ms at worst, measured).
