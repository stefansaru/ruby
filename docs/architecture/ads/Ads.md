# Advertising — retired

**Retired 2026-11-25.** The game ships with no advertising of any kind. This file
is kept because other docs link to it.

- **What it was.** From 2026-11-24 this page held the design for an adaptive
  banner at the bottom of every screen and a rewarded video that the player could
  choose to watch for hint coins, with consent gathered before the ad SDK started,
  test ad ids by default and production ids injected at release. It followed
  amethyst's working implementation. None of it was ever built: no ad code, no ad
  SDK and no consent code exists in this repository.
- **Why retired.** Owner ruling, 2026-11-25: "This puzzle should not be with ads."
  No banner, no rewarded video, no interstitial, no ad SDK, no consent flow for
  ads, no coins earned by watching ads.
- **What replaced it.** A free download with the tutorial and easy packs free, and
  one one-time purchase that unlocks the rest (recommended; the owner has not yet
  confirmed the price). See [Monetisation.md](../../strategy/Monetisation.md) and
  the requirements
  [APP-PAY-001..003](../../requirements/app_requirements/pay/). The retired
  requirements are [APP-ADS-001..004](../../requirements/app_requirements/ads/)
  and [APP-PRV-001](../../requirements/app_requirements/prv/APP-PRV-001.md).

The retired design itself is in git history (the version of this file committed
on 2026-11-24).
