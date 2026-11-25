# Monetisation

**Owner ruling, 2026-11-25: "This puzzle should not be with ads."** The game ships
with no advertising of any kind: no banner, no rewarded video, no interstitial, no
ad SDK, no consent flow for ads, and no hint coins earned by watching ads. *Why:*
the owner's decision; it also removes the genre's second-ranked complaint
([PainPointsAndConcepts.md](PainPointsAndConcepts.md) P2) at the root.

The model that replaces ads is below. **It is a recommendation from research and
the owner has not yet confirmed the price or the free part.** Until 2026-11-24 this
page described a banner plus rewarded video for hint coins; that model is retired
(see [History.md](../History.md) and [Ads.md](../architecture/ads/Ads.md)).

**Nothing about purchasing is built** (2026-11-25): no billing code, no unlock gate.
Every pack is open in the draft.

## The model (recommended, owner to confirm)

| Element | Decision | Why |
|---|---|---|
| Ads | **None, of any kind** (owner ruling 2026-11-25) | The owner's decision. Intrusive ads are the genre's second-ranked complaint |
| Download | Free | A player must be able to test fairness before paying; every direct rival is free to install |
| Free part | The tutorial pack and the easy pack, complete | Enough to learn the game and to know whether it is worth paying for. As of 2026-11-25 that is 200 cases (100 tutorial, 100 easy); the packs in `lib/data/` are the source for the counts |
| Paid part | **One one-time purchase** unlocks everything else: the normal, hard and expert packs (100, 100 and 36 cases as of 2026-11-25) and future packs unless stated otherwise | One decision, made once. The pattern of the premium puzzle apps this audience already pays for (comparables below) |
| Subscription | None | Out of proportion for a puzzle with no server; a subscription for a puzzle draws distrust |
| Energy, keys, timers | None | A competitor's daily keys draw complaints; a logic player gated from logic leaves |
| Coin packs, consumables | None | They need an economy to balance and they read as a trap next to a one-time price |
| Hints | Free in the current draft | See [Hints.md](../features/Hints.md). Whether anything hint-like is ever sold is open (below) |
| Play Pass, Apple Arcade | Not planned | Play Pass is by invitation with an interest form; Apple Arcade is pitched and has historically taken unreleased games. Neither can be planned on. Apply after launch |

## Rules

1. **No ads, anywhere, ever shown by this app.** No ad SDK is linked. *Why:* owner
   ruling 2026-11-25.
2. **One purchase.** There is a single product and it unlocks everything that is
   locked. *Why:* the player decides once and is never asked again.
3. **The free part is really playable.** Every tutorial and easy case is complete,
   with the same tools, hints and notes as a paid case, and with no timer, energy,
   key or daily limit. *Why:* a crippled trial is a dark pattern, and the free
   part is the only advertisement the game has.
4. **The price is shown before the gate.** A locked pack is marked as locked in
   the case list, and the screen that offers the purchase shows the store's
   localised price before the player taps buy. *Why:* nobody should discover the
   price by trying to pay.
5. **The purchase is restorable.** A player who reinstalls or changes phone gets
   it back from the store account, with a visible "Restore purchase" action.
   *Why:* store policy requires it for non-consumables, and a lost purchase is a
   one-star review.
6. **The purchase works offline once made.** The unlock is remembered on the
   device; a paid pack never waits on a network call. *Why:* the game plays
   offline (APP-QAL-003) and a puzzle is played on trains.
7. **No dark patterns.** No countdown offers, no fake discounts, no pop-up that
   interrupts a case, no purchase prompt after every solve, no pre-ticked
   anything. The offer appears when the player opens something locked, and in
   one fixed place in the menu. *Why:* value V3, respect for the player's time
   and attention.
8. **No energy, no keys, nothing locked by a timer.** *Why:* gates are a quoted
   reason for leaving a competitor.
9. **No rating prompt before a set number of solved cases, and never twice in a
   row.** *Why:* "Asks you to rate after every puzzle. Including the first."
   (APP-UX-006).

Requirements: [APP-PAY-001](../requirements/app_requirements/pay/APP-PAY-001.md),
[APP-PAY-002](../requirements/app_requirements/pay/APP-PAY-002.md),
[APP-PAY-003](../requirements/app_requirements/pay/APP-PAY-003.md),
[STRAT-MIS-001](../requirements/strategy_requirements/STRAT-MIS-001.md).

## Price (recommended, owner to confirm)

| | USD | EUR | GBP |
|---|---|---|---|
| Low | 3.99 | 4.49 | 3.49 |
| **Recommended** | **4.99** | **5.49** | **4.49** |
| High | 6.99 | 7.99 | 5.99 |

*Why 4.99:* one-time unlocks and packs in premium puzzle apps cluster at
$3.99–4.99 (EUR 5–6), and EUR 7.99 is the top of what was found (Roomers). The
market leader charges EUR 4.99 just to remove ads. The paper book lists at
$18.99 for 80 puzzles, about $0.11–0.24 a puzzle depending on discount; at $4.99
the paid packs as they stand today cost about 2 cents a case.

### Regional tiers (assumption, not researched per country)

| Tier | Share of full price | Countries |
|---|---|---|
| Full | 100% | US, Canada, Australia, western Europe, the Nordics |
| Middle | about 70% | Spain, Portugal, Italy, Poland, Czechia |
| Low | 35–50% | Latin America, Turkey, India, South-East Asia |

Spain is in the middle tier on purpose: it is the core market of the book this
genre comes from (more than 140,000 copies), so a lower price there is aimed at
the largest known audience.

## Revenue sketch per 10,000 installs

**Every figure in this section is an assumption unless a source is named.** It is
a way to see the order of magnitude, not a forecast.

- Store fee: about 15% (sourced, see "Store fees" below).
- A US sale: 4.99 − 15% = 4.99 × 0.85 = **$4.24** net.
- Blended net per sale after VAT in Europe and the regional discounts: assume
  **$3.50**.

| Share of installs that buy | Buyers | Net |
|---|---|---|
| 1% | 100 | 100 × 3.50 = **$350** |
| 3% | 300 | 300 × 3.50 = **$1,050** |
| 6% | 600 | 600 × 3.50 = **$2,100** |

The 3% is unproven. It leans on an audience that already pays about $19 for a
book of 80 puzzles. No recent puzzle-specific figure for free-to-unlock
conversion was found; the anchors are old: Gasketball 0.67% at $2.99
([2012](https://www.nbcnews.com/tech/tech-news/how-app-200-000-downloads-led-developer-homelessness-flna946720)),
Ionage 2.3% worldwide and 3.7% in the UK
([2013](https://www.gameanalytics.com/blog/an-indie-perspective-launching-a-f2p-game)),
and a general free-to-play range of 2–5%.

### Store fees

- **Google Play**, since 30 Jun 2026 in the US, EEA and UK: a 10% service fee on
  the first $1M plus a 5% billing fee, about 15% effective; elsewhere 15% on the
  first $1M. Confirm in the Play Console
  ([Play help](https://support.google.com/googleplay/android-developer/answer/16954621),
  [Android Developers blog](https://android-developers.googleblog.com/2026/06/play-expanded-billing.html)).
- **Apple**: 15% under $1M in the Small Business Program.
- **Play Pass** is invitation-only with an interest form
  ([RevenueCat](https://www.revenuecat.com/docs/google-play-pass)). **Apple
  Arcade** is pitched and has historically taken unreleased games only.

## Sourced and assumed

| Sourced (links on this page and in MarketResearch.md §7) | Assumed |
|---|---|
| Rivals' and comparables' prices and models | That this audience converts like premium puzzle buyers and not like a free-to-play crowd |
| The book's list prices and Spanish sales | The 1%, 3% and 6% conversion rows |
| Store fee percentages | The $3.50 blended net per sale |
| The old conversion anchors (2012, 2013) | The regional tiers and their percentages |
| | That the free part (tutorial and easy) is the right size |

All prices were seen on 2026-11-25, **mostly in search snippets and page
summaries, not on live store pages**. The live listings must be re-checked before
the price is decided.

## Comparables

The full table with sources is [MarketResearch.md](MarketResearch.md) §7. In
short:

| App | Model | Price seen |
|---|---|---|
| Enigmic (market leader) | Free, an ad after each case | Remove ads EUR 4.99; pack EUR 5.49; three-pack bundle EUR 9.49 |
| Roomers (iOS) | Free, no ads, 41 cases and a free daily | One-time unlock EUR 7.99 |
| Roomdoku (iOS) | Free with ads and consumables | Remove ads $4.99; consumables $0.49–7.99 |
| Killer Sudoku by Sudoku.com | Free with ads | Remove ads $4.99 |
| Good Sudoku | Free, one-time unlock | $3.99 at its 2020 launch; EUR 5.99 on EU storefronts |
| Cracking the Cryptic (Classic, Killer) | Paid upfront | $4.99 (EUR 5.99 in Austria) |
| Logic Grid Puzzles (Egghead) | Free with 100 puzzles, no ads | $3.99 per 100-puzzle pack; optional subscription |
| Star Battle Puzzles (Egghead) | Packs | $3.99 per 150 puzzles |
| The paper book | 80 puzzles | $18.99 list |

## Alternatives considered, and why not

| Alternative | Why not |
|---|---|
| **Ads** (banner, rewarded video, interstitial), the model until 2026-11-24 | Ruled out by the owner on 2026-11-25. Ads are also what this genre's players complain about most after wording, and an ad SDK brings consent, age handling and audio problems that a solo studio would have to carry |
| **Paid upfront** | Nobody can try the game first, and the game's claim (fair cases, exact clues) is one a player wants to test. Every direct rival is free to install, so a paid listing loses the comparison in search. Cracking the Cryptic can charge upfront because it has an audience before the store page |
| **Packs sold one by one** | More income per keen player, but more decisions for the player, more products to keep and test, and a list of prices that reads as nickel-and-diming. Could return later for large new packs if the owner decides future packs are not included (open, below) |
| **Subscription** | No server, no content that costs money each month, and puzzle players distrust a subscription for something a book gives for one price. One rival offers it; no evidence that it works here |
| **Free with nothing sold** | Honest, but it pays for nothing, including the art |

## Open, for the owner

- **Confirm the price**: $4.99 / EUR 5.49 / GBP 4.49, or another point in the
  range; and the regional tiers.
- **What exactly is free.** The recommendation is the tutorial and easy packs.
  Alternatives: a few cases of every tier free as a taste; the daily case free
  for everyone ([DailyCase.md](../features/DailyCase.md) says the daily case
  costs nothing; nothing here contradicts that, and nothing confirms it).
- **Whether extra statements or hints are ever sold.** The "+" on a character
  card that reveals one more true statement (built 2026-11-25, free) is a
  possible later paid item. The owner said: "perhaps these hints could be
  purchased at some point, for now they could be free." Recorded as open, not
  decided. If they are sold, rule 2 (one purchase) has to be reworded first.
- **Whether future packs are included** in the one purchase. The recommendation
  is yes unless stated otherwise at the time a pack is announced.
- **Family sharing** (Play Family Library, Apple Family Sharing) on or off.
