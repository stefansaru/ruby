# Monetisation

Decided 2026-11-24 (owner): the game follows the "4 Pics 1 Word" pattern as
amethyst implements it. Nothing on this page is built yet; the design is in
[Ads.md](../architecture/ads/Ads.md) and [Hints.md](../features/Hints.md).

## The model

| Element | v1 | Why |
|---|---|---|
| Price | Free | The audience expects it; only 6–7% of puzzle players buy anything in a month (TargetAudience.md) |
| Banner | One adaptive banner at the bottom of every screen | Passive income that interrupts nobody |
| Rewarded video | Only when the player asks, to earn hint coins | The format this audience accepts; the trade is stated before the ad plays |
| Interstitials | None | 43% of puzzle players say they quit over too many ads; it is the genre's second-ranked complaint |
| Energy, keys, locked cases | None | A competitor's daily keys draw complaints; a logic player gated from logic leaves |
| Coin packs | None in v1 | Keeps the first release free of purchases and their policy work |
| Remove-ads purchase | v2 | Paid-only competitors show the demand; needs billing, restore and tests |
| Subscription | None planned | Out of proportion for a puzzle with no server |

## Rules

1. **No ad starts while a case is open on screen, except the rewarded video the
   player has just agreed to.** *Why:* an interruption mid-deduction is what
   players quit over.
2. **An ad never changes the player's audio.** The game does not mute, duck or
   pause other apps' sound for an ad, and requests ads muted where the SDK
   allows. *Why:* "App mutes phone during ads" is a quoted one-star reason for
   the market leader.
3. **One coin balance, one price per hint, and one ad pays for the dearest
   hint.** *Why:* the offer needs no arithmetic (amethyst APP-GAM-015).
4. **The player confirms before the ad.** The dialog says what they lack, what
   plays and what they get.
5. **If the ad fails to load after the player agreed, they still get the
   reward, once per health snapshot.** *Why:* the player kept their side; the
   bound stops an offline player farming coins (amethyst APP-ADS-001 AC-4).
6. **When ads are unavailable, prices stay real.** Hints the player cannot
   afford are disabled, with the reason shown. No free fallback. *Why:*
   otherwise turning off the network is the cheapest hint.
7. **Coins are also earned by playing**: a grant on first solve of a case, and
   a starting grant on install. *Why:* a player who never watches an ad must
   still be able to use a hint now and then.
8. **No rating prompt before a set number of solved cases, and never twice in a
   row.** *Why:* "Asks you to rate after every puzzle. Including the first."

## How the reference game does it

4 Pics 1 Word: coins from solving, spent on hints; coin bags from $0.99 to
$19.99; a "Premium" at $5.99 that appears to be the ad-free product; reviews
complain about ad frequency
([Play](https://play.google.com/store/apps/details?id=de.lotum.whatsinthefoto.us),
[App Store](https://apps.apple.com/us/app/4-pics-1-word/id595558452)). We take
the coin-and-hint loop and the rewarded video, and leave the interstitials.

## Open, for the owner

- Whether v1 ships any purchase at all (current answer: no).
- Banner on the case screen: it is passive and amethyst shows it everywhere,
  so the design keeps it; rule 1 concerns ads that *start* or *cover* the case.
