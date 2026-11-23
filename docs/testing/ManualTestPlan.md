# Manual test plan

Written 2026-11-24. Checks a person does by hand, on top of the automated tests
(`docs/testing/Tests.md`). Cases are numbered `MT-<area>.<n>`; numbers are never reused. A
retired case keeps its row with "Retired <date>" in the Expected column.

This round built the engine, the generator and the packs, not the app. So **part A can be run
today** and **part B waits for the UI**; part B is written now so the UI is built to it.

Run from the repository root. All commands are for the Windows shell or bash alike.

## Part A — runnable now

### MT-1: Generating the packs

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-1.1 | Dry run matches the repository | `dart run tool/generate_cases.dart --dry-run` | Every pack line ends "unchanged". Exit code 0. No "NO CASE" line. |
| MT-1.2 | One tier only | `dart run tool/generate_cases.dart --only=tutorial --dry-run` | Only the tutorial pack is reported, "unchanged". |
| MT-1.3 | Probe | `dart run tool/generate_cases.dart --probe=3` | For each tier: "3/3 cases", a funnel line with six gates in the order scene, unique, wellFormed, logic, tier, variety, each number no larger than the one before, and a "hardest technique" line. No file in `lib/data/` changes (`git status`). |
| MT-1.4 | Tier really decides difficulty | Read the "hardest technique" lines of MT-1.3. | tutorial: only clue or single. easy: nothing above lastInLine. normal: only intersection or pair. hard: only subset or counting. expert: only whatIf or liarSplit. |
| MT-1.5 | Same seed, same case | Run MT-1.1 twice. | Both runs say "unchanged". |
| MT-1.6 | Verbose | `dart run tool/generate_cases.dart --only=easy --probe=3 --verbose` | One extra line per slot with its id, setting, grid shape, draws, time and hardest technique. |
| MT-1.7 | A changed pack is caught | Edit one character of a clue in `lib/data/cases_easy.dart`, run MT-1.1, then undo the edit (`git checkout lib/data/cases_easy.dart`). | The easy pack reports "DIFFERS" and the exit code is 1. After the undo, MT-1.1 passes again. |
| MT-1.9 | The honest sweep | `dart run tool/check_cases.dart` | One line per tier and a last line "All N cases are sound." Exit code 0. |
| MT-1.10 | Timing | `dart run tool/bench_gen.dart` | One line per sampled slot with draws, milliseconds and hardest technique; no "NO CASE". Note anything over a few seconds in `docs/Performance.md`. |
| MT-1.8 | Generated header | Open any `lib/data/cases_<tier>.dart`. | The first line says it is generated and must not be edited by hand, and names the command. |

### MT-2: Reading a case by hand

Pick cases by slot id so the check can be repeated; pick a different id each release.

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-2.1 | A tutorial case on paper | `dart run tool/show_case.dart tutorial 2` prints the grid, the areas and objects and each person's sentences as a player will read them. Draw the grid on paper and solve it using `docs/GameRules.md`. Then run the same command with `--answer`. | You reach one placement without guessing. It equals the printed answer, and the murderer you named is the one printed. The victim's area holds the victim and exactly one suspect. |
| MT-2.2 | An easy and a normal case on paper | Same, one case from each pack (`show_case.dart easy <n>`, `normal <n>`). | Same. The normal case needs at least one step that is more than "this person has one square left"; the printed steps (with `--answer`) name it. |
| MT-2.8 | Sentences read well | Read the printed sentences of ten cases across tiers, including one two-grid case. | Every sentence is plain English with one reading. Rows are numbers, columns letters, no compass words. On the two-grid case row and column sentences end "of her grid" / "of his grid". An either-or area sentence does not always name the true area first. |
| MT-2.3 | Words mean what the rules say | In the cases of MT-2.1 and MT-2.2, check each clue against section 4 of `docs/GameRules.md` on the solved grid: beside (same area, not diagonal), on, row and column numbering, above/below/left/right. | Every clue is true in the solution under the written meaning. None relies on a meaning the rules do not give. |
| MT-2.4 | Scene makes sense | In five cases from different settings, read the area names and where the objects are. | Areas are in one piece. No object sits in an area where it cannot be by the setting's inside/outside rule (`docs/Settings.md`). Note any pairing that reads oddly (a boat on a path) in `OpenIssues.md`; it is a known rough edge, not a failure. |
| MT-2.5 | Special shapes | Find in the hard pack one two-grid case, one 6 by 8 case and one case with `---` squares; in the expert pack one with `rule liar` and one with `rule notouch`. Check the `solution` line of each against its rule. | Two grids: one person per row and column inside each grid. 6 by 8: six people, one per row, two columns empty. Cut corners: nobody on a `---` square. Liar: exactly one statement is false in the solution. No touching: no two people on touching squares, diagonals included. |
| MT-2.6 | The murderer is never given away | In ten cases, read the clues of the murderer and of anyone else. | No statement says who was with the victim, and no "alone", "alone with", "same area" or "exactly N others" statement is made by a person standing in the victim's area. |
| MT-2.7 | Names and titles | Skim the `person`, `victim` and `title` lines of one whole pack. | Suspects have initials A, B, C... in order; the victim has a later initial; every id in a case is different. Titles are two plain words after "The". No title appears twice in any pack (also automated in `test/data/packs_test.dart`). |

### MT-3: The parser as a gate

Use a scratch copy of the starter case from `test/engine/fixtures.dart` inside a throwaway
test (the parser has no command-line entry of its own; `tool/check_cases.dart` only reads
the shipped packs). All of these are automated in `test/engine/case_text_test.dart`; they
are listed here as the quickest hand check after a format change.

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-3.1 | Wrong solution refused | Change the solution so two people share a row. | Rejected: "the stated solution is wrong: ... share a line", with the line number. |
| MT-3.2 | Broken clue refused | Change `clue A is on c` to `clue A is on t`. | Rejected: nobody can be on a table. |
| MT-3.3 | Split area refused | Change one corner square to an area that is not next to the rest of that area. | Rejected: the area is in more than one piece. |
| MT-3.4 | Victim cannot speak | Add `clue D is in P`. | Rejected: the victim gives no statement. |
| MT-3.6 | Cast too large refused | Add a fifth `person` line to the 4 by 4 starter case. | Rejected: the people cannot fit. |
| MT-3.7 | Door off a wall refused | Add `open Home 2 2 N door` (both squares are Garden). | Rejected: a door or window must be on a wall. |
| MT-3.5 | Round trip | Parse the starter case, write it, parse again. | The second text equals the first; the solution is unchanged. (Automated in `test/engine/`; listed here because it is the fastest sanity check after a format change.) |

## Part B — waits for the UI

Nothing below can be run yet. Each area names the doc it tests against.

### MT-10: Placing and winning (`docs/GameRules.md`)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-10.1 | Place a person | Select a suspect, tap a free square. | The token appears on the square. |
| MT-10.2 | Blocked square | Tap a square with a table. | Nothing is placed; the square shows it cannot be used. |
| MT-10.3 | Row and column | Place a second person in the same row as the first. | The game shows the clash; it does not silently accept it. |
| MT-10.4 | Coordinates visible | Open any case. | Columns show letters and rows show numbers on the grid edge, on every grid of a two-grid case. |
| MT-10.5 | Solve | Place everyone correctly. | The case ends; the murderer is named with the area they shared with the victim. |
| MT-10.6 | Wrong full placement | Place everyone, one person wrongly. | The case does not end as solved; no correct square is revealed for free. |
| MT-10.7 | Case rules shown | Open a 6 by 8 case, a liar case and a no-touching case. | "2 columns stay empty.", "Exactly one statement is false." and the no-touching sentence are shown above the statements. |
| MT-10.8 | Leave and return | Leave a half-solved case, close the app, reopen. | Placements and notes are as they were. |

### MT-11: Clues on screen (`docs/GameRules.md` sections 4 and 5)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-11.1 | Sentence matches the rules doc | Compare ten on-screen statements with the catalogue. | Same sentences; key words bold. |
| MT-11.2 | Tap a clue | Tap "She was beside a table." | Exactly the squares beside a table (same area, not diagonal, usable) are highlighted. Free. |
| MT-11.3 | Victim card | Look at the victim. | "The victim. He/She was alone with the murderer." and no other statement. |
| MT-11.4 | Small screen | Open a 9 by 9 case on the smallest supported phone. | Every square can be tapped without hitting its neighbour; statements are readable without zooming. |

### MT-12: Notes (`docs/features/Notes.md`)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-12.1 | Per-suspect mark | Mark "Anna could be here" on two squares. | The marks carry Anna's letter and colour. |
| MT-12.2 | Per-suspect cross | Cross a square out for Ben only. | Other suspects can still be marked there. |
| MT-12.3 | Auto-eliminate | Turn it on, place Cora. | Cora's row and column are crossed for everyone. Turned off: nothing is crossed. |
| MT-12.4 | Undo | Place, mark, cross, then undo three times. | Each undo reverses one action, notes included. |

### MT-13: Hints and coins (`docs/features/Hints.md`)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-13.1 | Explained step | Ask for the strongest hint on a fresh case. | It names a technique from `docs/Techniques.md`, the person and the square, and offers to place it. |
| MT-13.2 | Hint follows the board | Place two people correctly, ask again. | The hint is about a later step, not one already done. |
| MT-13.3 | Wrong board | Place someone wrongly, ask for a hint. | The hint says something placed is wrong; it does not build on the mistake. |
| MT-13.4 | Price | Note the coin balance, take a hint. | The balance drops by that hint's price, once. |
| MT-13.5 | Cannot afford | With too few coins, tap a hint. | A dialog explains the trade (watch an ad for coins) with No and Yes. No: nothing happens. |
| MT-13.6 | Ad buys the hint | Yes, watch the ad to the end. | Coins are credited and the hint is given without a second tap. |
| MT-13.7 | Ad closed early | Yes, close the ad before the reward. | No coins, no hint. |

### MT-14: Ads (`docs/architecture/ads/Ads.md`)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-14.1 | Consent first | Fresh install in a consent region. | The consent form comes before any ad. |
| MT-14.2 | Banner | Open a case. | The banner sits outside the grid and the statements and never covers a square. |
| MT-14.3 | Nothing interrupts | Solve three cases in a row. | No full-screen ad appears unless the player asked for one. |
| MT-14.4 | Player's audio | Play music from another app, watch a rewarded ad. | Record what happens to the music; the store listing claim must match. |
| MT-14.5 | Offline | Airplane mode, open a case, tap an unaffordable hint. | The case plays; the hint explains ads are unavailable; nothing is given free. |

### MT-15: Daily case (`docs/features/DailyCase.md`, proposed)

| # | Test case | Steps | Expected |
|---|---|---|---|
| MT-15.1 | Same for everyone | Open the daily case on two devices. | The same case. |
| MT-15.2 | Streak | Solve on two days running, skip one. | The streak counts 2, then resets. |
| MT-15.3 | Share card | Share a result. | The card shows time and hints used and reveals no square and no name. |
