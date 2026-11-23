# Advertising — design

**Status: design only, 2026-11-24. No ad code exists in this repository.**
This page is the plan for when it is built. It follows amethyst's working
implementation (`amethyst/docs/architecture/ads/Ads.md`, `APP-ADS-001`); where
this page and amethyst differ, the difference is stated with its reason.

Requirements: [APP-ADS-001..004](../../requirements/app_requirements/ads/),
[APP-PRV-001](../../requirements/app_requirements/prv/APP-PRV-001.md).
Product rules: [Monetisation.md](../../strategy/Monetisation.md).

## Formats

| Format | Used | Where |
|---|---|---|
| Adaptive anchored banner | Yes | Bottom of every screen |
| Rewarded video | Yes | Only after the player confirms, to earn hint coins |
| Interstitial | **No** | — |
| App-open, native, playable | **No** | — |

## Order of start-up

1. The app starts with **no ad SDK call**.
2. Consent is gathered (Google's UMP form where required, plus whatever age
   handling the legal review decides).
3. `ConsentService.adsReady` becomes true. **This is the only definition of
   "ads may run"**; every ad component reads it and none re-derives it.
4. `MobileAds.initialize()` is called, with the request configuration that the
   consent and age answers require.
5. Only then may the banner load.

*Why one definition:* amethyst's audits found that two components each
deciding "are ads allowed" will eventually disagree.

## Planned components

| Component | Planned path | Job |
|---|---|---|
| `AdHelper` | `lib/helpers/ad_helper.dart` | Supplies unit ids. Reads `BANNER_AD_UNIT_ID` and `REWARDED_AD_UNIT_ID` from `--dart-define`; **falls back to Google's published test ids** when they are absent. `assertProductionIds()` fails a store build that still carries test ids. |
| `ConsentService` | `lib/services/consent_service.dart` | Consent state and `adsReady`. |
| `BannerAdWidget` | `lib/widgets/banner_ad_widget.dart` | One banner, placed once in `MaterialApp.builder` so it sits under every screen. One load in flight at a time; backoff after a failed load; reserved height snaps to the served creative so there is no gap. |
| `RewardedAdService` | `lib/services/rewarded_ad_service.dart` | The confirm dialog, load, show, and the reward callback. |
| `AdHealthMonitor` | `lib/services/ad_health_monitor.dart` | A snapshot of "can a rewarded ad be offered", taken when a case opens. Holds the one-failure-grant latch. |
| `HintBudgetService` | `lib/services/hint_budget_service.dart` | The coin balance (see [Hints.md](../../features/Hints.md)). |

## Banner

- Bottom of the screen, below all content, with a thin divider. It is never
  drawn over the grid or the clue list, and the layout is designed with its
  height already taken out.
- Not shown during the consent flow.
- It stays visible on the case screen. It is passive and does not start,
  cover or interrupt anything.
- **Thumb reach:** the lowest row of controls sits directly above the banner.
  A manual test on a small phone must confirm that taps on the tools do not
  land on the ad. Accidental ad taps are a policy problem as well as an
  annoyance.

## Rewarded video

The flow is in [Hints.md](../../features/Hints.md) §The ad flow. The parts
that belong to this page:

- The ad is loaded **after** the player says Yes, not before.
- **Load failure after Yes:** the reward is granted, once per health snapshot.
  After the grant the offer is withdrawn until the next snapshot.
- **Loaded but dismissed early:** no reward.
- **Not offerable** (no consent, SDK not ready, latch used): the offer is not
  made, and the reason is shown.

## Rules that differ from "whatever the SDK does by default"

1. **No ad starts on a case screen except the confirmed rewarded video.**
2. **The player's audio is left alone.** Ads are requested muted
   (`MobileAds.setAppMuted(true)` / volume 0 where available), and the app
   requests no audio focus on behalf of an ad. *Why:* a quoted reason for
   one-star reviews of the market leader. *To verify when built:* a rewarded
   video may take audio focus on its own on some devices; test with music
   playing and record the result here. If the SDK cannot be stopped from
   doing so, this rule and the listing copy that rests on it must be reworded.
3. **Playable and long unskippable formats are excluded** in the AdMob
   console where the console allows it. *Why:* "playable ads that you cannot
   exit" is a quoted complaint.
4. **Content categories are restricted** to suit the declared audience
   (RiskAnalysis.md R4).

## Build and release

- Debug and internal builds always run on test ids.
- `build_release` scripts (PowerShell and bash twins, to be written) inject
  the production ids with `--dart-define`, set a `STORE_BUILD` flag, and
  refuse to run from a branch other than `main`.
- `app-ads.txt` on jini.solutions needs this app's line once the AdMob app
  exists. That is part of the website work, which is a TODO item.

## Not decided

- Age handling and whether the app declares a mixed audience (owner and legal
  review; see `amethyst/docs/legal/` for the pattern).
- The `google_mobile_ads` version to pin.
