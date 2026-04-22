# PROJECT_CONTEXT: Horizon Realm Baseline

## Mission
Establish a production-ready baseline for **Horizon Realm**, a high-performance hybrid Minecraft environment on **Arclight 1.20.1** that fuses Soulslike combat systems with MMORPG progression.

## Technical Direction
- Hybrid Forge/Paper compatibility through Arclight
- Java 21 runtime with tuned JVM startup flags
- Service-oriented local stack:
  - Arclight game server container
  - MariaDB persistence backend
  - Redis cache/state backend

## Gameplay Pillars
1. Soulslike combat feel (timing, commitment, stamina pressure, boss patterns)
2. MMORPG persistence (classes, progression, guilds, economies, long-term progression)
3. High extensibility for mods/plugins integration

## Planned Primary Integrations
- Forge Mods: Epic Fight Mod, Mowzie’s Mobs, Iron's Spells 'n Spellbooks
- Paper Plugins: MMOCore, MythicMobs, ModelEngine, Guilds, TokenManager

## Economy Baseline
- Coins: high-circulation operational currency
- Horizon Shards: scarce progression currency for premium sinks and long-term retention

## Repository Foundation Goals
- Keep runtime noise (logs/world data/crash artifacts) out of git
- Keep configuration and structure version-controlled
- Maintain clear operational scripts for deterministic startup and deployment
