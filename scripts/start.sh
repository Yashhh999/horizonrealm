#!/usr/bin/env bash
set -euo pipefail

SERVER_ROOT="/data/server-root"
ARCLIGHT_JAR="${SERVER_ROOT}/arclight-1.20.1.jar"
JVM_XMS="${JVM_XMS:-12G}"
JVM_XMX="${JVM_XMX:-12G}"

mkdir -p "${SERVER_ROOT}" "${SERVER_ROOT}/logs"

if [[ ! -f "${ARCLIGHT_JAR}" ]]; then
  echo "[INFO] Missing Arclight server jar at: ${ARCLIGHT_JAR}"
  echo "Downloading Arclight 1.20.1..."
  wget -qO "${ARCLIGHT_JAR}" "https://github.com/IzzelAliz/Arclight/releases/download/Trials/1.0.6/arclight-forge-1.20.1-1.0.6.jar" || curl -sL -o "${ARCLIGHT_JAR}" "https://github.com/IzzelAliz/Arclight/releases/download/Trials/1.0.6/arclight-forge-1.20.1-1.0.6.jar"
  if [[ ! -f "${ARCLIGHT_JAR}" ]]; then
    echo "[ERROR] Failed to download Arclight 1.20.1 jar."
    exit 1
  fi
fi

cd "${SERVER_ROOT}"

echo "eula=true" > eula.txt

exec java \
  -Xms"${JVM_XMS}" \
  -Xmx"${JVM_XMX}" \
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
