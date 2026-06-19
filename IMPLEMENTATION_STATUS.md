# Idle Coffee Empire — Implementation Status

> Last updated: 2026-06-17

---

## Quick Summary

**~80–85% of a playable idle game is complete.**
All core gameplay, progression, and UI are fully working. All external integrations (backend, IAP, audio, ads, analytics) are intentionally mocked/stubbed pending SDK wiring.

---

## Fully Implemented ✅

### Core Game Loop
- Flame `update()` tick driving production, order creation, customer spawning, and UI events
- `GameController.tick()` handles all per-frame game logic
- Station task queuing and completion system
- XP and level progression integrated into tick
- Floating coin popups and UI event triggers (milestone, prestige, expansion)
- Autosave every 15 seconds

### Station System
- 3 MVP stations: Espresso Machine, Coffee Grinder, Pastry Display
- Station unlock (coin threshold) and upgrade logic
- Upgrade cost scaling: `baseUpgradeCost × level^1.38`
- Profit per tap: `baseProfit × stationLevel`
- Auto-enable/disable toggle
- `StationComponent` renders progress bars, level display, status text, upgrade badges
- Station bonus milestone system

### Worker System
- 3 MVP workers: Barista, Burger Cook, Pastry Chef
- Hire and upgrade (2 levels with efficiency multipliers)
- `WorkerComponent` renders animated sprites with bobbing and delivery-path animation
- Cook count calculation based on worker levels

### Customer System
- Customer spawning with type-based colors and patience timers
- Queue management (max 5) with visual positioning
- Seated customer tracking at cafe tables (max 8)
- 6 customer types: Regular, Student, Tourist, VIP, Office Worker, Influencer
- Order bubble UI showing items and patience status
- Tips system on order completion
- Patience-based order failure and customer-leave animation

### Economy
- All profit/cost formulas implemented and tuned
- Coins per second calculation
- Offline income (0.6× rate, 2-hour cap) via `OfflineIncomeSystem`
- Boost multiplier composition (multiple boosts stack correctly)

### Expansion System
- 6 cafe stages: Small Coffee Cart → Cozy Cafe → Busy Coffee Shop → Downtown Cafe → Premium House → Empire HQ
- Requirement checking: lifetime coins earned + customers served
- Income multiplier and customer spawn rate increase per stage
- Theme integration per expansion tier

### Prestige / New Game+
- Point formula: `sqrt(lifetimeCoins / 90000)`
- Permanent multiplier: `1.0 + (prestigePoints × 0.05)`
- Full prestige reset logic with reward payout
- Prestige achievements (4 metric types tracked)
- Permanent upgrades that carry across prestiges

### Achievements
- 6 metric types: lifetime coins, customers served, decorations placed, workers hired, stations unlocked, player level
- Progress calculation, completion detection, reward claiming (coins + XP)
- Full UI panel with progress bars

### Milestones
- Progression checkpoints with bonus rewards
- UI panel mirroring achievement structure

### Boosts
- 4 boost types: Income ×2, Production Speed ×2, Customer Rush ×2, custom
- Time-based with expiration tracking
- Gem purchase and ad-reward flows wired to boost activation
- Multiple boosts stack correctly

### LiveOps
| Feature | Status |
|---|---|
| Daily Rewards | 7-day cycle, streak reset on missed days, UI with day progression |
| Tasks | Daily + weekly objectives, metric tracking, reward claiming |
| Limited Events | Event multiplier composition (profit, spawn rate, VIP chance, decoration cost, etc.) |
| Achievements | Full UI with filter, progress bars, claim button |

### Save / Load System
- Hive-based persistence (save version 8, 100+ serialized fields)
- Primary + backup save with validation (sanity checks on coins/stations)
- Version migration system for forward compatibility
- Full state coverage: stations, workers, progression, prestige, events, cosmetics

### Tutorial System
- Step-by-step guided flow with UI highlights
- Completion tracking, skip, and restart
- Key steps: unlock grinder → upgrade espresso → hire worker → enable auto → prestige intro

### UI Screens & Panels
All panels render **live game data** — no placeholder widgets anywhere.

| Panel | Notes |
|---|---|
| GameScreen / HUD | Coins, gems, orders, level, offline income banner, bottom nav |
| Stations Sheet | Browse all stations, upgrade/unlock with cost display |
| Workers Panel | Hire/upgrade with cost |
| Prestige Panel | Confirmation dialog, point preview, reset |
| Boosts Panel | Active/inactive boosts, purchase with gems or ad |
| Achievements Panel | Progress bars, claimable rewards |
| Milestones Panel | Same structure as achievements |
| Daily Reward Panel | 7-day cycle display, claim button |
| Tasks Panel | Daily/weekly with progress and rewards |
| Store Panel | Free rewards, boosts, settings |

### Cafe Scene
- Shop map sprite loading from asset with procedural fallback rendering
- Fallback draws floor, walls, stations, tables, counter, entrance, queue area
- Zone system for positioning stations and customer seating

---

## Partially Implemented ⚠️

### Cafe Scene Visuals
- **Floor color / evolution tier**: `setFloorColor()` and `setEvolutionTier()` in `cafe_scene.dart` are empty stubs — theme tinting and stage-based visual evolution are not applied
- **Station sprites**: Don't change with level or theme

### Decorations
- Decoration system, configs, manager, and component all exist
- `_syncDecorations()` in `idle_coffee_game.dart` **clears all decorations but never respawns them** — decorations are currently invisible in-game even when purchased

---

## Stubbed / Mocked (Not Connected) 🔴

All of these have proper abstract interfaces and mock implementations. The game runs fine with mocks. Real SDK wiring is pending.

| System | What exists | What's missing |
|---|---|---|
| **Backend API** | `BackendApiClient` interface + `MockBackendApiClient` | Real HTTP client / server endpoints |
| **Cloud Save** | `CloudSaveService` interface + mock | Real upload/download logic |
| **Authentication** | `AuthService` interface + mock (always guest) | Real auth provider (Firebase, etc.) |
| **IAP** | `IapService` interface + `MockIapService` (always succeeds) | Receipt validation, store kit integration |
| **Audio** | `AudioService` API + enum for all SFX | `play()` is an intentional no-op — audio asset mapping and player not connected |
| **Haptics** | `HapticsService` stub | No-op; platform haptics not called |
| **Rewarded Ads** | `MockAdService` (returns success instantly) | Real AdMob/rewarded ad load + show |
| **Analytics** | Events collected in `MockAnalyticsService` | Never forwarded to production SDK |
| **Crash Reporting** | `CrashService` interface + mock | No real crash logging |
| **Remote Config** | `MockRemoteConfigService` (local overrides only) | Real remote config fetch |
| **Live Events** | `MockLiveEventManager` always used | Real events from backend not connected |

---

## Asset Status

| Asset type | Status |
|---|---|
| Station sprites (3 MVP) | Present |
| Worker sprites (3 types) | Present |
| Customer sprites (6 types) | Present |
| UI elements (buttons, panels, icons, HUD) | Present |
| Floor / background art | Present |
| Audio files (music + SFX) | `.gitkeep` placeholders — no audio content yet |
| Station sprites (tiers 4–10) | Defined in configs but assets may be placeholders |

---

## What to Build Next

Based on the current state, logical next steps are:

1. **Fix decorations rendering** — `_syncDecorations()` needs to respawn components after clearing
2. **Wire audio** — map `GameSfx` enum to asset files and swap out the stub `play()` body
3. **Cafe visual evolution** — implement `setEvolutionTier()` and `setFloorColor()` in `cafe_scene.dart`
4. **Real IAP** — replace `MockIapService` with platform store kit
5. **Real ads** — replace `MockAdService` with AdMob rewarded ad flow
6. **Backend + cloud save** — implement `BackendApiClient` against real server
7. **Analytics** — forward events in `MockAnalyticsService` to production SDK
8. **Audio assets** — populate `assets/audio/sfx/` and `assets/audio/music/`
