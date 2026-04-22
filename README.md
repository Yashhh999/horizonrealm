# Horizon Realm (Arclight 1.20.1 Hybrid Stack)

Horizon Realm is a **hybrid Minecraft server architecture** built on **Arclight 1.20.1** to combine:
- **Forge mod combat depth** (Soulslike gameplay)
- **Paper plugin MMORPG systems** (economy, guilds, progression)

## Core Stack

- **Server Core:** Arclight 1.20.1 (Forge + Paper compatibility)
- **Primary Mods:**
  - Epic Fight Mod
  - Mowzie’s Mobs
  - Iron's Spells 'n Spellbooks
- **Primary Plugins:**
  - MMOCore
  - MythicMobs
  - ModelEngine
  - Guilds
  - TokenManager
- **Data Layer:** MariaDB (persistent relational data), Redis (high-speed cache/session state)

## Repository Layout

- `/server-root` → Arclight runtime root, jar, generated server data
- `/plugins-configs` → versioned plugin configuration baselines
- `/mods` → Forge modpack artifacts for deployment
- `/resource-pack` → custom assets, models, UI resources
- `/scripts` → operational scripts (bootstrap/start/maintenance)

## Runtime Architecture

`docker-compose.yml` provisions three services:
1. **arclight** (Java 21 runtime) running `scripts/start.sh`
2. **mariadb** for persistent plugin/mod data
3. **redis** for caching, sessions, fast lookups, queue/state patterns

## Economy Design (Dual Currency)

### Coins (Soft Currency)
- Earned through mobs, quests, dungeons, and trade.
- Used for routine market transactions, repairs, consumables, and travel.
- High circulation; balancing focuses on sinks and inflation control.

### Horizon Shards (Premium Progression Currency)
- Scarce currency tied to major content milestones and seasonal rewards.
- Used for class awakenings, rare crafting catalysts, elite rerolls, and prestige systems.
- Intentionally limited to protect long-term progression pacing.

## Soulslike Combat Direction

Combat is built around **commitment and timing**, not spam:
- Stamina/resource pressure during attack chains and evasions
- Animation-committed actions (Epic Fight)
- High-threat encounter scripting (MythicMobs + custom AI)
- Pattern recognition and punish windows for bosses
- Risk/reward loop for death, recovery, and progression attempts

This supports an MMORPG endgame while preserving deliberate, high-skill combat identity.

## Quick Start

1. Place `arclight-1.20.1.jar` in `/server-root`.
2. Ensure plugin and mod assets are mounted/configured.
3. Start stack:
   ```bash
   docker compose up -d
   ```
4. Check service health/logs:
   ```bash
   docker compose ps
   docker compose logs -f arclight
   ```
