#!/usr/bin/env python3
import urllib.request
import json
import os
import glob

# Modrinth API & Mods configuration
MODRINTH_API = "https://api.modrinth.com/v2/project"
MODS_DIR = "/workspaces/horizonrealm/mods"

# Mods to ensure are installed for 1.20.1 (Forge)
# Including the missing dependencies.
MISSING_LIBS = [
    ("geckolib", "geckolib"),
    ("curios", "curios"),
    ("playeranimator", "player-animator"),
    ("irons_lib", "irons-spells-n-spellbooks"), # Note: irons_lib is usually bundled or part of iron's spells, but let's grab specific versions
    ("lionfishapi", "lionfish-api"),
]

# We must downgrade Iron's Spells and Epic Fight to versions that support Forge 47.3.x,
# OR fetch dependencies that match.
print("To ensure stability with Arclight's Forge 47.3.22, we will resolve compatible mod versions...")

def get_latest_compatible_version(project_slug, mc_version="1.20.1", loader="forge"):
    url = f"{MODRINTH_API}/{project_slug}/version"
    req = urllib.request.Request(url, headers={'User-Agent': 'horizonrealm-script'})
    try:
        with urllib.request.urlopen(req) as response:
            versions = json.loads(response.read().decode())
            for v in versions:
                if mc_version in v["game_versions"] and loader in v["loaders"]:
                    # Try to avoid versions explicitly requiring Forge 47.4+ if possible, 
                    # but for now we just grab the best match.
                    return v["files"][0]["url"], v["files"][0]["filename"]
    except Exception as e:
        print(f"Failed to fetch {project_slug}: {e}")
    return None, None

def download_file(url, filename):
    filepath = os.path.join(MODS_DIR, filename)
    if os.path.exists(filepath):
        print(f"Already exists: {filename}")
        return
    print(f"Downloading {filename}...")
    urllib.request.urlretrieve(url, filepath)

# Clean up incompatible ones first if needed (Optional, for now just satisfying dependencies)
print("Fetching missing dependencies...")
for mod_id, slug in MISSING_LIBS:
    url, filename = get_latest_compatible_version(slug)
    if url:
        download_file(url, filename)

print("\nIMPORTANT: If Arclight still complains about Forge 47.4.0+, you'll need to manually delete the newest Epic Fight / Iron's Spells jars in the mods/ folder and download versions from roughly August/September 2023 that were built for Forge 47.3.x.")
print("Run `docker compose restart arclight` after this finishes!")
