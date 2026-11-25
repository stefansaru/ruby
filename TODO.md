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

## Resume here (2026-11-25)

Three rounds are done: foundations; fixes after the first play (objects in their
areas, victim V and last, easy readable off the grid); fixes after the second play
(checklist statements, extras, area names, titles, no stray doors, random cases, cat
mode, saved progress, no ads). Since then: an audit, exploratory tests with a second
witness, area names on wall-coloured tabs, and a study of other screens with a trial
on a TV. The draft still uses placeholder shapes. Next, in this order:

1. The owner generates the art from `output/prompts/` (items 37, 38; eleven prompts
   and a README with the order) and the cutter is ported (39).
2. The owner plays the build and approves or changes the copy (58 to 60).
3. Wide screens and keys (72, 73), then the TV decision (74).
4. The rename (49), then the purchase (section 4).

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
13. [ ] Coverage floor in the doctor script. Measured 2026-11-25: 99.96% of the
    hand-written lines in `lib/`. Left: a small script that fails under a floor
    (proposed 98%) and a line in the commit checklist. **(gate)**

## 2. The playable case

14. [ ] Case screen. Draft done (`lib/screens/case_screen.dart`,
    `lib/widgets/case_grid.dart`): lettered columns, numbered rows, a colour per
    area, area names along the walls, walls, objects as labelled tiles, doors and
    windows where a clue uses them, character cards, rule sentences. Left: real
    art, polish.
15. [ ] Place and remove a person. Draft done by tap (select a card, tap a square;
    tap the person to lift them); clashes get a red ring; blocked squares are
    refused; squares in the row and column of a placed person get a cross; a tap
    on a placed person only lifts them; the placed card is greyed and the next
    person selected and scrolled to. Left: drag, undo.
16. [ ] Win check. Draft done: a "Case solved" card naming the murderer and the
    area, with "Next case". Left: a proper solved screen, the wording approved by
    the owner. **(owner)**
17. [ ] Tap a clue to preview the squares it allows (free).
18. [ ] Tutorial: the first tutorial cases with guided steps from the logic solver.
    Draft done: a "How to play" sheet of three steps in the menu.
19. [ ] Case list. Draft done: a tab per tier, green ticks saved on the device, a
    "Generate a random case" button under each list. Left: group by setting, order
    rules, the purchase gate (item 57).
20. [ ] Settings screen (sound, auto-eliminate, colour-blind safe palette, large text).
21. [ ] Layout for small phones, large phones and tablets, portrait first. **(device)**
22. [ ] Accessibility pass: contrast, tap targets, screen reader labels for squares
    ("B3, Kitchen, chair"). **(device)**

## 3. Notes and hints

23. [ ] Notes: per-suspect candidate marks and crosses, undo, auto-eliminate toggle
    (docs/features/Notes.md).
24. [ ] Hint sentences: turn a `LogicStep` into a sentence per technique
    (docs/Techniques.md has proposals). Draft done: `describeStep` in
    `lib/engine/wording.dart`, one sentence per technique. Player-facing copy.
    **(owner)** to approve the wording.
25. [ ] Hint ladder on screen: show squares, who is next, explain and place
    (docs/features/Hints.md). The draft has one free hint button with two steps:
    first who to look at and any step that cannot be read off the grid, then on a
    second tap the square (`CaseSession.hint`, `describeHint`); the card can be
    closed. Left: showing the squares on the grid.
26. [ ] "Something is wrong" hint when the player's placements contradict the clues.
    Partly there: a broken statement shows a red cross as soon as it is contradicted.
28. [ ] Measure the logic solver on a low-end phone; move it off the UI thread if a
    hint takes longer than a blink. **(device)**

## 4. Purchase (no ads: owner ruling 2026-11-25)

Items 27, 29 to 34 and 36 (coins, consent for ads, banner, rewarded video, ad
health, ad ids, audio check, AdMob account) were dropped with that ruling; see the
DoneLog. docs/strategy/Monetisation.md has the model and the evidence.

35. [ ] One purchase that unlocks everything beyond the free packs (it was "remove
    ads, v2"; it is now the whole model and v1). Billing on Google Play, restore,
    works offline once bought. **(gate)**
56. [ ] Confirm the price ($4.99 / EUR 5.49 / GBP 4.49 recommended) and the regional
    tiers; re-check the rivals' live listings first. **(owner)**
57. [ ] Decide what is free (recommended: tutorial and easy) and build the gate on
    the other tabs: the price is shown before anything is locked. **(owner)** for
    the split.
61. [ ] Decide whether extra statements ("+") or hints are ever sold. Today both are
    free. **(owner)**
80. [ ] Decide whether future packs are included in the one purchase (recommended:
    yes) and whether family sharing is on (docs/strategy/Monetisation.md).
    **(owner)**
62. [ ] Play Pass and Apple Arcade: apply after launch, once there are ratings.

## 5. Art and sound

37. [ ] One art question is left in docs/Art.md section 10: suspect colour as a
    disc under a neutral token, or tokens drawn in several colours. The others
    were answered on 2026-11-25. **(owner)**
38. [ ] Generate the sheets from `output/prompts/` and drop them in `input/`. **(owner)**
    Eleven prompts (regenerated 2026-11-25): floors, four object sheets, people,
    cats, interface, icon, store banner, TV banner.
    `output/prompts/README.md` gives the order and what to check.
39. [ ] Port the named-tile cutter and atlas builder from pushy when the first sheet
    arrives; accepted sheets to `sprites/`, prompts to `sprites/prompts/`.
40. [ ] App icon and store feature graphic. **(owner)**
41. [ ] Sounds: place, remove, wrong, solved; a mute setting.
42. [ ] Decide what the store listing says about how the art is made. **(owner)**
77. [ ] Draw the game with the art once sheets are accepted: floors per area, object
    and token sprites in place of the labelled tiles and discs, the interface
    marks; a second token atlas for cat mode. After 39.
78. [ ] Android adaptive icon (foreground and background layers) and a launch screen
    from the accepted icon; today both are Flutter's defaults.
79. [ ] Choose a font and ship it in `assets/fonts/`. No special font for now
    (owner, 2026-11-25): the platform font stays until this is taken up.

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

49. [ ] **Rename the game.** "Detective Sudoku" clashes with Cluedoku, whose store
    title is "Cluedoku: Detective Sudoku" (owner ruling 2026-11-24: change it).
    Steps: (a) shortlist names and check each against the Play Store, the App Store
    and trademark registers; (b) owner picks **(owner)**; (c) update the app title
    in `lib/main.dart` and `lib/screens/home_screen.dart`, the Android label and iOS
    display name, README, CLAUDE.md, the store listing and campaign drafts and the
    strategy docs; (d) decide whether the package id `com.jinisolutions.ruby` and
    the codename stay (they can: neither is shown to players). Until then the
    working title stays in the code and docs. **(gate)**
50. [ ] Store listing, screenshots, content rating questionnaire (murder theme,
    no gore), data safety form. **(owner)**
51. [ ] Privacy policy and the legal checks that still apply without ads (children, data safety).
52. [ ] `build_internal` / `build_release` script twins, signing, versioning.
53. [ ] Manual test plan run on real devices. **(device)** **(gate)**
54. [ ] **Website page for Detective Sudoku** on jini.solutions: a `SiteApp` entry,
    page and privacy modules in `amethyst/lib/wizard/website/`, an icon, then
    `py -3 lib/wizard/wizard.py --website`. Deliberately not done yet (owner,
    2026-11-24): keep it here until the game has a name check and an icon.
55. [ ] CI on GitHub: confirm the workflow in `.github/workflows/dart.yml` runs green
    on the first push.

## 9. Modes and copy (added 2026-11-25)

58. [ ] Approve or change the new player-facing copy: hint lines (`describeHint`,
    `describeStep`), "How to play" (`howToPlay`), the solved line, the cat-mode
    words (docs/features/Modes.md has them side by side). **(owner)**
59. [ ] Cat mode beyond words: cat names, cat sprites (prompt written; she-cats
    ginger, he-cats blue-grey, owner 2026-11-25), and the few statements that say
    "person", "women" or "men". **(owner)** for names.
60. [ ] Play the new build: are the ticks, the "+", the greyed cards and the area
    names right? Is any title or object pairing still odd? **(owner)**
63. [ ] A third mode, "missing item" ("who took the cookies"), on the same engine.
64. [ ] Time a random hard and expert case on the phone (ManualTestPlan MT-16.10);
    if it is slow, pre-generate a spare case per tier in the background. **(device)**
65. [ ] Expert pack size: the other four packs hold 100, expert 36. **(owner)**
66. [ ] Clue wording "in the Path" / "in the First Class" reads badly for some
    areas; needs a preposition per area ("on the Path"). Player-facing copy.

67. [ ] APP-GAM-002 asks for a "submit" step; the draft checks by itself on the last
    placement. Decide which the game does and make the other agree. **(owner)**
68. [ ] The longest functions (`drawScene`, `listCandidates`, `chooseClues`, the
    parser's main loop, the case screen's `build`) are over a hundred lines. Split
    when next changed; splitting the generator must not reorder its random calls.
69. [ ] Wide objects (bed, boat) are drawn as two tiles; the art draws them as one,
    lying left-right, and the game must turn the sprite for top-bottom.
81. [ ] Save a half-solved board so a case can be resumed (APP-GAM-012; OpenIssues
    3.4). Today only ticks, the mode and opened extras are saved.
82. [ ] More kinds of expert case: most need "what if", liar cases are the only
    other flavour (OpenIssues 1.4). Depends on 5 and on 83.
83. [ ] Teach the logic solver to count across statements ("exactly N in an area"
    from two clues together). Today such cases are thrown away, which costs
    yield, not correctness (OpenIssues 2.1). v2.
84. [ ] Cat mode in the store: say in the listing and the content rating which
    telling is the default, if cat mode is to widen the audience
    (docs/features/Modes.md). **(owner)**

70. [ ] Run a first hand-exploration session with the charters in
    docs/testing/Exploratory.md section 5 and record findings. **(owner)** or anyone
    who has not written the code.
71. [ ] Deep exploratory run (`RUBY_EXPLORE=20`) and `tool/plant_bugs.py` before each
    release. **(gate)** for release, not for commits.

## 10. Other screens (investigated 2026-11-25, docs/features/Screens.md)

Recommended order: 72, 73, 74, then 75 (docs/features/Screens.md).

72. [ ] Type and spacing scale chosen from the shorter side of the screen (phone,
    tablet, TV), applied through the theme; case list in two or three columns on
    wide screens; cards in two columns beside the grid when there is room.
73. [ ] Keyboard, remote and game pad: a cursor on the grid moved by arrows or the
    D-pad, OK doing what a tap does (`CaseSession.tap`); keys for next and previous
    person, hint, one more statement, close the message, restart and back; a
    visible focus ring on every control, the grid focused first; a widget test
    that plays a case with keys only, and a planted bug in `tool/plant_bugs.py`
    for "a key does something a tap would not".
74. [ ] Decide whether TV is a target. Tried on the BRAVIA 2015 on 2026-11-25: it
    runs, the remote opens cases and hints, no square can be reached and no focus
    is visible (docs/features/Screens.md). **(owner)** to judge it on the sofa.
75. [ ] Google TV: launcher entry, banner, touchscreen not required, TV layout with safe
    margins, Play Console TV form factor. Only after 73 and 74.
76. [ ] Build and run once on iOS and on the web; neither has been built yet. On the
    web also check the load size (the packs are source).
85. [ ] Manual pass on a real tablet, with split-screen and a foldable's inner
    display (ManualTestPlan). Nothing has been run on a tablet. **(device)**
86. [ ] Try the Chromecast HD on the owner's network (a real Google TV, Android 14)
    once 73 exists; the BRAVIA trial was on Android 7. **(device)**
87. [ ] Desktop (Windows, macOS, Linux): not set up. Needs 73, a minimum window
    size, and a meaning for hover and right-click. v2.
88. [ ] Put the build with the area-name tabs on the owner's phone (it was not
    connected on 2026-11-25), and decide whether the app stays on the BRAVIA.
    **(device)** **(owner)**

## Parked (do not start without an owner ruling)

- Ranked duels, co-op, level editor, community cases: competitors have them; they
  are a different product size.
- A second mode in the "clues reveal clues" style.
- Approaching the book's author about a licence.

## Waiting on the owner right now

- Item 49: pick the new name (a shortlist is step a).
- Items 58 and 60: play the new build and approve or change the new copy.
- Item 56 and 57: the price and what is free.
- Item 59: cat names and art, if cat mode is to be more than words.
- Item 65: should expert also hold 100 cases?
- Item 37: the one art question left (suspect colours).
- Item 1: play some cases on paper and say whether they are fun.
- Item 8: should "corner of the grid" count the squares around a cut corner? Today it does.
- Item 16: approve the wording of the solved card.
- Item 24: approve the hint sentences (`describeStep`).
- Item 38: generate the art sheets from `output/prompts/`.
- Item 42: what the store listing says about how the art is made.
- Item 46: the daily case: generated on the device or shipped ahead, v1 or v2.
- Item 61: are extra statements ("+") or hints ever sold? Today both are free.
- Item 67: a "submit" step, or the check by itself on the last placement as today?
- Item 74: is TV a target? Judge the BRAVIA build from the sofa.
- Item 80: are future packs included in the purchase; is family sharing on?
- Item 84: which telling the store listing leads with, if cat mode stays.
- Item 88: plug the phone in for the tab build; keep or remove the app on the TV.
