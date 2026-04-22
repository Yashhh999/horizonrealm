#!/usr/bin/env python3
from __future__ import annotations

import os
import stat
import subprocess
import sys
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
EULA_PATH = BASE_DIR / "eula.txt"
START_SH = BASE_DIR / "start.sh"
START_BAT = BASE_DIR / "start.bat"


def ensure_eula_true(eula_path: Path) -> bool:
    if eula_path.exists():
        original_text = eula_path.read_text(encoding="utf-8", errors="ignore")
        lines = original_text.splitlines()
    else:
        original_text = ""
        lines = [
            "# By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA)."
        ]

    updated_lines = []
    found_eula_line = False
    for line in lines:
        if line.strip().lower().startswith("eula="):
            updated_lines.append("eula=true")
            found_eula_line = True
        else:
            updated_lines.append(line)

    if not found_eula_line:
        if updated_lines and updated_lines[-1].strip():
            updated_lines.append("")
        updated_lines.append("eula=true")

    new_text = "\n".join(updated_lines).rstrip("\n") + "\n"
    if new_text != original_text:
        eula_path.write_text(new_text, encoding="utf-8")
        return True
    return False


def ensure_executable(path: Path) -> None:
    mode = path.stat().st_mode
    path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def run_start_script() -> int:
    if os.name == "nt":
        if not START_BAT.exists():
            print("[first-run-setup] Missing start.bat. Cannot continue.")
            return 1
        command = ["cmd", "/c", START_BAT.name]
    else:
        if not START_SH.exists():
            print("[first-run-setup] Missing start.sh. Cannot continue.")
            return 1
        ensure_executable(START_SH)
        command = ["bash", START_SH.name]

    print(f"[first-run-setup] Launching {' '.join(command)}")
    return subprocess.call(command, cwd=str(BASE_DIR))


def main() -> int:
    changed = ensure_eula_true(EULA_PATH)
    if changed:
        print("[first-run-setup] eula.txt was updated to eula=true.")
    else:
        print("[first-run-setup] eula.txt already set to eula=true.")

    return run_start_script()


if __name__ == "__main__":
    sys.exit(main())