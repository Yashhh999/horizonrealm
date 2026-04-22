#!/bin/bash
mv /workspaces/horizonrealm/server-root/mods /workspaces/horizonrealm/server-root/mods_disabled
mkdir /workspaces/horizonrealm/server-root/mods
mv /workspaces/horizonrealm/mods /workspaces/horizonrealm/mods_disabled
mkdir /workspaces/horizonrealm/mods
docker compose restart arclight
