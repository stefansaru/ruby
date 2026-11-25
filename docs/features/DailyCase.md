# Daily Case

**Status: proposed 2026-11-24 for v2. Not built, not scheduled, and not yet
ruled on by the owner.** Requirement:
[APP-GAM-010](../requirements/app_requirements/gam/APP-GAM-010.md).

## Why

Three competitors run a shared daily case, and it fits an audience that found
the genre through social video: one case, the same for everyone, something to
compare. It is also the cheapest reason to open the app tomorrow.

## Proposal

- **One case a day, the same for every player**, chosen by date from a pack
  generated ahead of time. No server is needed: the date indexes the pack.
  The day changes at local midnight.
- **A difficulty rhythm through the week**, easy on Monday to expert on
  Sunday. *(A competitor does this; it gives each weekday a character.)*
- **Streak:** consecutive days solved. Missing a day ends the streak; there is
  no paid repair. *Why:* a streak you can buy back is a charge for forgetting.
- **Past days stay playable** from a calendar, without counting for the streak.
- **Share card:** an image or text with the date, the tier, the time taken and
  the number of hints, and a row of plain marks for the order people were
  placed. **Never the murderer, a name, or a position.** *Why:* the card must
  be safe to post where others have not played yet.
- **No gate:** the daily case costs nothing.

## What must be decided first

1. How far ahead the pack is generated, and what happens when it runs out
   (an app update, or generation on the device from the date as seed; the
   second needs the generator to be allowed in the app, which the architecture
   allows through one service since 2026-11-25 (GEN-023,
   `lib/services/random_case.dart`)).
2. Whether time is shown at all. A timer changes a calm puzzle into a race.
3. Whether the streak is worth its cost in pressure for this audience.
