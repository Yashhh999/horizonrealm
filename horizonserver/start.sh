#!/usr/bin/env bash
set -u

STOP_REQUESTED=0
JAVA_PID=""

handle_stop_signal() {
  STOP_REQUESTED=1
  if [[ -n "${JAVA_PID}" ]] && kill -0 "${JAVA_PID}" 2>/dev/null; then
    echo "[start.sh] Stop signal received. Shutting down server process..."
    kill -TERM "${JAVA_PID}" 2>/dev/null || true
  fi
}

trap handle_stop_signal INT TERM

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}" || {
  echo "[start.sh] Failed to change directory to ${SCRIPT_DIR}"
  exit 1
}

JAR_FILE="server.jar"
RESTART_DELAY_SECONDS=5
HEAP_MIN="${HEAP_MIN:-2G}"
HEAP_MAX="${HEAP_MAX:-6G}"

if [[ ! -f "${JAR_FILE}" ]]; then
  echo "[start.sh] Missing ${JAR_FILE} in ${SCRIPT_DIR}"
  exit 1
fi

if [[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME}/bin/java" ]]; then
  JAVA_CMD="${JAVA_HOME}/bin/java"
else
  JAVA_CMD="java"
fi

if [[ "${JAVA_CMD}" == "java" ]] && ! command -v "${JAVA_CMD}" >/dev/null 2>&1; then
  echo "[start.sh] Java was not found on PATH. Install Java 21 or set JAVA_HOME."
  exit 1
fi

if ! JAVA_VERSION_LINE="$("${JAVA_CMD}" -version 2>&1 | head -n 1)"; then
  echo "[start.sh] Unable to execute Java. Install Java 21 or set JAVA_HOME."
  exit 1
fi

JAVA_MAJOR="$(echo "${JAVA_VERSION_LINE}" | sed -E 's/.*version "([0-9]+)(\.[^"]*)?".*/\1/')"
if [[ "${JAVA_MAJOR}" != "21" ]]; then
  echo "[start.sh] Java 21 is required. Detected: ${JAVA_VERSION_LINE}"
  exit 1
fi

JVM_FLAGS=(
  "-Xms${HEAP_MIN}"
  "-Xmx${HEAP_MAX}"
  "-XX:+UseG1GC"
  "-XX:+ParallelRefProcEnabled"
  "-XX:MaxGCPauseMillis=200"
  "-XX:+UnlockExperimentalVMOptions"
  "-XX:+DisableExplicitGC"
  "-XX:+AlwaysPreTouch"
  "-XX:G1NewSizePercent=30"
  "-XX:G1MaxNewSizePercent=40"
  "-XX:G1HeapRegionSize=8M"
  "-XX:G1ReservePercent=20"
  "-XX:G1HeapWastePercent=5"
  "-XX:G1MixedGCCountTarget=4"
  "-XX:InitiatingHeapOccupancyPercent=15"
  "-XX:G1MixedGCLiveThresholdPercent=90"
  "-XX:G1RSetUpdatingPauseTimePercent=5"
  "-XX:SurvivorRatio=32"
  "-XX:+PerfDisableSharedMem"
  "-XX:MaxTenuringThreshold=1"
  "-Dusing.aikars.flags=https://mcflags.emc.gs"
  "-Daikars.new.flags=true"
)

echo "[start.sh] Java version check passed: ${JAVA_VERSION_LINE}"
echo "[start.sh] Heap profile: -Xms${HEAP_MIN} -Xmx${HEAP_MAX}"
echo "[start.sh] Launching ${JAR_FILE} with --nogui and restart-on-crash loop."

while true; do
  "${JAVA_CMD}" "${JVM_FLAGS[@]}" -jar "${JAR_FILE}" --nogui &
  JAVA_PID=$!
  wait "${JAVA_PID}"
  EXIT_CODE=$?
  JAVA_PID=""

  if [[ ${STOP_REQUESTED} -eq 1 ]]; then
    echo "[start.sh] Stop requested. Exiting without restart."
    exit 0
  fi

  if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "[start.sh] Server stopped cleanly (exit code 0). Not restarting."
    exit 0
  fi

  if [[ ${EXIT_CODE} -eq 130 || ${EXIT_CODE} -eq 143 ]]; then
    echo "[start.sh] Server terminated by signal (exit code ${EXIT_CODE}). Not restarting."
    echo "[start.sh] If this was memory pressure, try: HEAP_MIN=2G HEAP_MAX=5G ./start.sh"
    exit 0
  fi

  echo "[start.sh] Server crashed with exit code ${EXIT_CODE}. Restarting in ${RESTART_DELAY_SECONDS}s..."
  sleep "${RESTART_DELAY_SECONDS}"
done