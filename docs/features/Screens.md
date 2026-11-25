# Screens: landscape, tablets, TV and other sizes

**Status: investigated 2026-11-25. The layout already adapts; a remote or keyboard cannot
play yet; nothing TV-specific is built.**

The owner asked how the game can be played in landscape, on a tablet or on Google TV, and
whether it ports to other screen sizes. This file records what was checked, what works
today, what does not, and what each target needs.

## How it was checked

- The case screen and the case list were rendered at the sizes below with the real fonts
  and looked at (`output/shots/`, not committed).
- `test/screens/edges_test.dart` already lays out a tutorial, a two-grid and a 9 by 9 case
  at 780x360, 700x760, 320x568 and 1024x768 and fails on any overflow or any square that
  cannot be tapped; `test/explore/fuzz_test.dart` taps at random at four sizes.
- The Android manifest, the iOS plist and the source were read for orientation locks,
  launcher entries and focus or key handling.
- **Run on a TV** (owner's BRAVIA 2015, Android 7.0, 1920x1080, 32-bit; release build
  installed and started over the network, keys sent as a remote would). See "On the
  BRAVIA" below.
- **Not done:** nothing was run on a tablet. A Chromecast HD (a Google TV, Android 14) is
  also on the network and was not touched.

## What works today

| Target | Size checked | State |
|---|---|---|
| Phone, portrait | 360x780, 320x568 | The designed layout: grid above (at most 58% of the height), cards below. |
| Phone, landscape | 780x360 | Works. Grid on the left, cards on the right (`LayoutBuilder`, wider than tall). The grid shrinks to the height; nothing is clipped (fixed in the audit). Only about three cards fit beside it. |
| Tablet, landscape | 1280x800 | Works. Two grids sit side by side with room; a single grid leaves empty space below the cards. |
| Tablet, portrait | 800x1280 | Works. The grid is large; text stays phone-sized. |
| TV picture | 960x540 (a 1080p TV) | The layout fits and reads like the phone in landscape. **Cannot be operated**, see below. |
| Rotation | | Not locked on Android; iOS allows portrait and both landscapes (all four on iPad). The board survives rotation because it lives in the session, not the layout. |

Why it adapts without special code: the grid is drawn from its own size
(`GridGeometry`), the screen picks side-by-side or stacked from the space it is given, and
no size is fixed in pixels.

## On the BRAVIA (2026-11-25)

- **It installs and runs** on a nine-year-old 32-bit Android 7 TV. The case list and a
  case draw correctly at 1080p; text is readable up close, small from a sofa.
- **The remote works for ordinary controls.** Down, down, OK opened a case from the list;
  on the case screen the D-pad reached the hint button and OK showed the hint, twice,
  down to "Adam was on C2".
- **No square can be reached**, as predicted: the grid takes no focus. A case cannot be
  played with the remote.
- **There is no visible focus.** Nothing on screen shows which control the remote is on,
  so even the reachable controls are operated blind.
- **It is not on the TV's home screen**: it was started by command. Without the TV
  launcher entry a user cannot open it.
- The bottom row of the grid sits a few pixels from the screen edge; a TV that crops its
  picture would cut it.

So TV is feasible. What it needs is exactly the list below: a grid cursor, a visible
focus, the launcher entry and banner, larger type and safe margins.

## What does not work

1. **Nothing but a finger can play.** The grid is one painted surface that only hears
   taps. It has no focus, no cursor and no keys. A TV remote, a keyboard or a game pad
   can reach the buttons and the cards (they are ordinary controls) but never a square.
   This blocks Google TV outright and makes Chromebooks, desktop and web awkward.
2. **Google TV would not even list it.** The manifest has no TV launcher entry
   (`LEANBACK_LAUNCHER`), no TV banner image, and does not say a touchscreen is optional,
   so the Play Store hides it from TVs and it would not appear on the TV home screen.
3. **Text is sized for a hand, not a sofa.** On a tablet the statements are small beside a
   large grid; on a TV at three metres they are too small. Nothing scales type or spacing
   with the screen.
4. **Space is wasted on wide screens.** The case list is one full-width column of rows.
   With one grid in landscape the cards column is narrow and tall while half the screen is
   empty under it.
5. **No TV-safe margins.** Some TVs cut off the picture's edge (overscan); content should
   stay about 5% in from each side.
6. **Hover and right-click mean nothing** on desktop and web. Minor.

## What each target needs

### Landscape phones and tablets (small work, no new input)

- A type and spacing scale chosen from the shorter side of the screen (phone, tablet,
  TV), applied through the theme. *Why the shorter side:* it is what distinguishes a
  tablet from a phone on its side.
- Case list: two or three columns of cards on wide screens.
- Case screen, wide: let the cards use two columns when there is room; keep the grid at
  the height of the screen.
- A manual pass on a real tablet (ManualTestPlan), including split-screen and a foldable's
  inner display. Since Android 16, large screens ignore orientation locks, so supporting
  both is required there, not optional; the app already does.

### Keyboard, remote and game pad (the real work; unlocks TV, Chromebook, desktop, web)

- **A cursor on the grid.** The grid takes focus; arrow keys or the D-pad move a
  highlighted square; OK/Enter does what a tap does (`CaseSession.tap`, already in the
  engine, so no game logic moves). The cursor is view state, like the hint text.
- **Keys for the rest:** next and previous person, hint, restart, one more statement,
  close the message, back. On a remote: D-pad, OK, Back, and Play/Pause for the hint.
- **Focus order and a visible focus ring** on every control; the first focus on opening a
  case is the grid.
- **Tests:** drive a whole case with key events only, in the widget tests; add a planted
  bug for "a key does something a tap would not".
- The rule "the engine decides, the view draws" already holds, so this is a second way of
  sending the same taps, not a second game.

### Google TV (after the cursor exists)

- Manifest: the `LEANBACK_LAUNCHER` category, `android.software.leanback` and
  `android.hardware.touchscreen` both declared not required, a 320x180 banner image.
- A TV layout: landscape only, larger type, 5% safe margins, statements beside the grid,
  nothing that needs scrolling by touch.
- Play Console: opt in to the TV form factor; TV apps are reviewed against Google's TV
  quality list (full D-pad navigation, no touch-only features, banner, readable text).
- Saved progress (`shared_preferences`) works on TV as on phones. The purchase, when it is
  built, must work with a remote.
- Check that the oldest TV to support runs the app at all: old Android TVs are 32-bit and
  on old Android versions.
- **Is a logic puzzle with a page of text right for a TV?** It is a second-screen,
  shared-sofa use: one person with the remote, others reading. Worth a trial on the
  owner's TV before any polish. **(owner)**

### Other sizes

| Target | Needs |
|---|---|
| Foldables | Nothing beyond the tablet work; test the fold and the half-open posture. |
| Chromebooks | The keyboard work; they also run the Android build as is, with a mouse standing in for a finger. |
| iPad | The tablet work. The project has an iOS target; nothing has been built or run on iOS yet. |
| Web | The project has a web target; never built. Needs the keyboard work and a check of load size (the packs are source). |
| Windows, macOS, Linux | Not set up (`flutter create --platforms`); would need the keyboard work and a window-size minimum. |
| Watches, cars | Not suitable: the grid needs room and attention. |

## Recommended order

1. Type scale and the wide case list (helps every tablet and landscape phone).
2. The grid cursor and keys, with tests.
3. A trial on the owner's TV with a debug build; decide whether TV is a target.
4. Only then the TV manifest, banner and layout.

See TODO items 72 to 76.
