# TODO — Detective Sudoku (ruby)

Only outstanding work lives here. Finished work is in
[docs/process/DoneLog.md](docs/process/DoneLog.md); known faults are in
[OpenIssues.md](OpenIssues.md); why things are the way they are is in the docs
([docs/README.md](docs/README.md)).

Rules of this list:

- **v1 means "must be true before the first Google Play release".** v2 is after.
- Items are numbered once, continuously across sections, and never renumbered. A
  closed item leaves a gap; other docs cite the number.
- When an item is done it moves to the DoneLog with its date.

Legend: `[ ]` open · `[x]` done, waiting to be moved · **(owner)** only the owner can
do or decide it · **(device)** needs a phone or emulator · **(gate)** must be green
before release.

## Resume here (2026-11-24)

Round 1 is finished: docs, engine, solvers, generator, packs, tests, all gates green.
Nothing on screen yet. The next step is section 2 (the playable case screen with
placeholder shapes), then section 3 (notes and hints), because every later item needs
a case you can play. Before that, the owner questions in "Waiting on the owner" decide
the name and the art.

## 1. Rules and content (engine and generator)

1. [ ] Play twenty generated cases on paper across the tiers (`tool/show_case.dart`)
   and record what felt unfair, dull or mis-graded in `output/`. Tune `Family`
   weights and tier ranges from that. **(owner)** for the verdict on fun.
2. [ ] Grid capacities with empty grids (several small grids, some empty; a grid is
   empty or full). Needs a capacity per grid in the format and the solver's
   full-line rule per grid.
3. [ ] Partly usable large objects (front and back seat of a car, the back half of a
   boat): per-square "can hold a person" inside one object.
4. [ ] "Someone who..." clues ("she was in a row above someone on a chair").
5. [ ] Use the clue types the engine has but the generator never draws: everyone
   except, two-axis exact offsets, "on exactly 1 or 3 sides", negated front/corner.
6. [ ] Objects placed with sense: a boat on water only, a car on a road or in a
   garage. Needs a terrain tag per area in `lib/data/settings.dart`.
7. [ ] Two-grid cases: split areas by floor or side sensibly (no Garden upstairs).
8. [ ] Irregular grids: decide whether "corner of the grid" should count the squares
   around a cut corner. Today it does. **(owner)**
9. [ ] Case intro line per case (one sentence of story) and a closing line naming
   the murderer; templates per setting.
10. [ ] Later rules, each needing a design in docs/GameRules.md first: two-time-slot
    timeline, testimony revealed as you place, weapon and motive, locked doors and
    keys, conditional clues, margin counts. v2.
11. [ ] Pin the setting of each slot in `gen_campaign.dart` so that adding a setting
    does not reshuffle the packs.
12. [ ] Difficulty within a tier: use the solver's score to order cases easiest first
    inside each pack.
13. [ ] Coverage floor for `lib/engine/` and `lib/gen/` in the doctor script, once
    measured. **(gate)**

## 2. The playable case

14. [ ] Case screen: grid with lettered columns and numbered rows, areas, walls,
    objects, doors and windows; suspect cards with their statements; rule sentences.
    Placeholder shapes until art exists.
15. [ ] Place and remove a person by tap or drag; refuse nothing, mark conflicts.
16. [ ] Win check against the certified solution; "case solved" screen naming the
    murderer and the area.
17. [ ] Tap a clue to preview the squares it allows (free).
18. [ ] Tutorial: the six tutorial cases with guided steps from the logic solver.
19. [ ] Case list by tier and setting; progress saved on the device.
20. [ ] Settings screen (sound, auto-eliminate, colour-blind safe palette, large text).
21. [ ] Layout for small phones, large phones and tablets, portrait first. **(device)**
22. [ ] Accessibility pass: contrast, tap targets, screen reader labels for squares
    ("B3, Kitchen, chair"). **(device)**

## 3. Notes and hints

23. [ ] Notes: per-suspect candidate marks and crosses, undo, auto-eliminate toggle
    (docs/features/Notes.md).
24. [ ] Hint sentences: turn a `LogicStep` into a sentence per technique
    (docs/Techniques.md has proposals). Player-facing copy. **(owner)** to approve.
25. [ ] Hint ladder on screen: show squares, who is next, explain and place
    (docs/features/Hints.md).
26. [ ] "Something is wrong" hint when the player's placements contradict the clues.
27. [ ] Hint coins: one balance, prices and rewards as named constants in
    `lib/data/config_default.dart`.
28. [ ] Measure the logic solver on a low-end phone; move it off the UI thread if a
    hint takes longer than a blink. **(device)**

## 4. Ads and money

29. [ ] Consent first (UMP), then `MobileAds.initialize`; age handling.
30. [ ] Banner on the app shell, never covering the grid; hidden with the keyboard.
31. [ ] Rewarded video for coins: confirm dialog, reward, re-run the hint
    (docs/architecture/ads/Ads.md).
32. [ ] Ad health monitor and the one-grant rule when a load fails after opt-in.
33. [ ] Test ad ids by default, production ids by `--dart-define`, build script that
    refuses to run without them. **(gate)**
34. [ ] Check with music playing that a rewarded video does not leave the player's
    audio muted; reword the claim if it does. **(device)**
35. [ ] One-time remove-ads purchase. v2.
36. [ ] AdMob account, app id, ad units, app-ads.txt. **(owner)**

## 5. Art and sound

37. [ ] Answer the art questions in docs/Art.md (wide objects, victim marker, token
    colours, font). **(owner)**
38. [ ] Generate the sheets from `output/prompts/` and drop them in `input/`. **(owner)**
39. [ ] Port the named-tile cutter and atlas builder from pushy when the first sheet
    arrives; accepted sheets to `sprites/`, prompts to `sprites/prompts/`.
40. [ ] App icon and store feature graphic. **(owner)**
41. [ ] Sounds: place, remove, wrong, solved; a mute setting.
42. [ ] Decide what the store listing says about how the art is made. **(owner)**

## 6. Languages

43. [ ] Move clue wording behind a per-language interface; English stays the
    reference and the test fixture.
44. [ ] Spanish, Dutch, German first (where the books sold); each needs gender and
    article rules for objects and areas. Order is a proposal. **(owner)**
45. [ ] Translate setting, area and object names; keep them short.

## 7. Daily case and sharing

46. [ ] Daily case: one shared case per day from a date-seeded slot
    (docs/features/DailyCase.md). Needs a decision: generated on the device or
    shipped ahead. v1 or v2: **(owner)**
47. [ ] Streak and calendar.
48. [ ] Spoiler-free share card.

## 8. Release

49. [ ] Name check: "Detective Sudoku" is the subtitle of a competing app
    (Cluedoku). Search the stores and trademark registers; decide to keep or change.
    **(owner)**
50. [ ] Store listing, screenshots, content rating questionnaire (murder theme,
    no gore), data safety form. **(owner)**
51. [ ] Privacy policy and the legal checks amethyst has (consent, children). 
52. [ ] `build_internal` / `build_release` script twins, signing, versioning.
53. [ ] Manual test plan run on real devices. **(device)** **(gate)**
54. [ ] **Website page for Detective Sudoku** on jini.solutions: a `SiteApp` entry,
    page and privacy modules in `amethyst/lib/wizard/website/`, an icon, then
    `py -3 lib/wizard/wizard.py --website`. Deliberately not done yet (owner,
    2026-11-24): keep it here until the game has a name check and an icon.
55. [ ] CI on GitHub: confirm the workflow in `.github/workflows/dart.yml` runs green
    on the first push.

## Parked (do not start without an owner ruling)

- Ranked duels, co-op, level editor, community cases: competitors have them; they
  are a different product size.
- A second mode in the "clues reveal clues" style.
- Approaching the book's author about a licence.

## Waiting on the owner right now

- Item 49: keep the name "Detective Sudoku" or change it.
- Item 37: the art questions.
- Item 1: play some cases on paper and say whether they are fun.
- Monetisation: is a banner on the case screen acceptable, or only on menus
  (docs/strategy/Monetisation.md)?
