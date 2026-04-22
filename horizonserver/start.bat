@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

set "JAR_FILE=server.jar"
set "RESTART_DELAY_SECONDS=5"
if "%HEAP_MIN%"=="" set "HEAP_MIN=2G"
if "%HEAP_MAX%"=="" set "HEAP_MAX=6G"

if not exist "%JAR_FILE%" (
  echo [start.bat] Missing %JAR_FILE% in %CD%
  pause
  exit /b 1
)

set "JAVA_CMD=java"
if defined JAVA_HOME (
  if exist "%JAVA_HOME%\bin\java.exe" set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
)

"%JAVA_CMD%" -version >nul 2>&1
if errorlevel 1 (
  echo [start.bat] Java was not found. Install Java 21 or set JAVA_HOME.
  pause
  exit /b 1
)

set "JAVA_VERSION_LINE="
for /f "usebackq delims=" %%L in (`"%JAVA_CMD%" -version 2^>^&1`) do (
  if not defined JAVA_VERSION_LINE set "JAVA_VERSION_LINE=%%L"
)

set "JAVA_VERSION_RAW="
for /f "tokens=3" %%V in ("!JAVA_VERSION_LINE!") do set "JAVA_VERSION_RAW=%%~V"

set "JAVA_MAJOR="
for /f "tokens=1 delims=." %%M in ("!JAVA_VERSION_RAW!") do set "JAVA_MAJOR=%%M"

if not "!JAVA_MAJOR!"=="21" (
  echo [start.bat] Java 21 is required. Detected: !JAVA_VERSION_LINE!
  pause
  exit /b 1
)

set "JAVA_FLAGS=-Xms%HEAP_MIN% -Xmx%HEAP_MAX% -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

echo [start.bat] Java version check passed: !JAVA_VERSION_LINE!
echo [start.bat] Heap profile: -Xms%HEAP_MIN% -Xmx%HEAP_MAX%
echo [start.bat] Launching %JAR_FILE% with --nogui and restart-on-crash loop.

:restart
"%JAVA_CMD%" %JAVA_FLAGS% -jar "%JAR_FILE%" --nogui
set "EXIT_CODE=%ERRORLEVEL%"

if "%EXIT_CODE%"=="0" (
  echo [start.bat] Server stopped cleanly ^(exit code 0^). Not restarting.
  pause
  exit /b 0
)

if "%EXIT_CODE%"=="130" (
  echo [start.bat] Server terminated by signal ^(exit code 130^). Not restarting.
  echo [start.bat] If this was memory pressure, try: set HEAP_MIN=2G ^&^& set HEAP_MAX=5G ^&^& start.bat
  pause
  exit /b 0
)

if "%EXIT_CODE%"=="143" (
  echo [start.bat] Server terminated by signal ^(exit code 143^). Not restarting.
  echo [start.bat] If this was memory pressure, try: set HEAP_MIN=2G ^&^& set HEAP_MAX=5G ^&^& start.bat
  pause
  exit /b 0
)

echo [start.bat] Server crashed with exit code %EXIT_CODE%. Restarting in %RESTART_DELAY_SECONDS%s...
timeout /t %RESTART_DELAY_SECONDS% /nobreak >nul
goto restart