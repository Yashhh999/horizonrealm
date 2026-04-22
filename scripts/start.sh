#!/usr/bin/env bash
set -euo pipefail

SERVER_ROOT="/data/server-root"
ARCLIGHT_JAR="${SERVER_ROOT}/arclight-1.20.1.jar"

if [[ ! -f "${ARCLIGHT_JAR}" ]]; then
  echo "[ERROR] Missing Arclight server jar at: ${ARCLIGHT_JAR}"
  echo "Place Arclight 1.20.1 jar in /server-root before starting."
  exit 1
fi

mkdir -p "${SERVER_ROOT}" "${SERVER_ROOT}/logs"

exec java \
  -Xms12G \
  -Xmx12G \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+DisableExplicitGC \
  -XX:+AlwaysPreTouch \
  -XX:G1NewSizePercent=30 \
  -XX:G1MaxNewSizePercent=40 \
  -XX:G1HeapRegionSize=8M \
  -XX:G1ReservePercent=20 \
  -XX:G1HeapWastePercent=5 \
  -XX:G1MixedGCCountTarget=4 \
  -XX:InitiatingHeapOccupancyPercent=15 \
  -XX:G1MixedGCLiveThresholdPercent=90 \
  -XX:G1RSetUpdatingPauseTimePercent=5 \
  -XX:SurvivorRatio=32 \
  -XX:+PerfDisableSharedMem \
  -XX:MaxTenuringThreshold=1 \
  -Dusing.aikars.flags=https://mcflags.emc.gs \
  -Daikars.new.flags=true \
  -jar "${ARCLIGHT_JAR}" \
  nogui
