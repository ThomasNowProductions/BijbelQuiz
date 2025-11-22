#!/usr/bin/env python3
"""Release helper script for BijbelQuiz.

Usage:
    python3 update_release.py <new_version>

The script will:
  1. Update `app/pubspec.yaml` (or the pubspec.yaml in the Flutter project root) with the new version **and increment the build number**.
  2. Increment Android `versionCode` and set `versionName` in the appropriate `build.gradle`.
  3. Replace the version string in `websites/bijbelquiz.app/download.html`.
  4. Run Flutter builds for web, Android APK, Android App Bundle (AAB) and Linux.
  5. Copy the generated web build into `websites/play.bijbelquiz.app`.

All operations abort on first error to avoid partial releases.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# ---------- Helper utilities ----------

def run_cmd(command: list[str], cwd: Path | None = None) -> None:
    """Run a command, streaming output, and raise on failure."""
    print(f"[RUN] {' '.join(command)} (cwd={cwd})")
    result = subprocess.run(command, cwd=cwd, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command {' '.join(command)} failed with exit code {result.returncode}")

def read_file(path: Path) -> str:
    return path.read_text(encoding="utf-8")

def write_file(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")

def find_flutter_root(start: Path) -> Path:
    """Walk upwards from *start* until a directory containing pubspec.yaml is found.
    Returns the directory containing the pubspec.yaml (the Flutter project root).
    """
    current = start.resolve()
    while True:
        if (current / "pubspec.yaml").exists():
            return current
        if current.parent == current:
            raise RuntimeError("Could not locate a pubspec.yaml in any parent directory.")
        current = current.parent

# ---------- 1️⃣ Update pubspec.yaml (bump version & build number) ----------
def update_pubspec(project_root: Path, new_version: str) -> None:
    pubspec_path = project_root / "pubspec.yaml"
    content = read_file(pubspec_path)
    match = re.search(r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)", content, re.MULTILINE)
    if not match:
        raise RuntimeError("Could not find version line in pubspec.yaml")
    old_version, old_build = match.group(1), int(match.group(2))
    new_build = old_build + 1
    new_line = f"version: {new_version}+{new_build}"
    new_content = re.sub(r"^version:.*", new_line, content, flags=re.MULTILINE)
    write_file(pubspec_path, new_content)
    print(f"Updated pubspec.yaml: {old_version}+{old_build} → {new_version}+{new_build}")

# ---------- 2️⃣ Update Android build.gradle ----------
def update_build_gradle(project_root: Path, new_version: str) -> int:
    # The gradle file lives under <project_root>/android/app/build.gradle
    gradle_path = project_root / "android" / "app" / "build.gradle"
    content = read_file(gradle_path)
    # versionCode
    code_match = re.search(r"versionCode\s+(\d+)", content)
    if not code_match:
        raise RuntimeError("versionCode not found in build.gradle")
    old_code = int(code_match.group(1))
    new_code = old_code + 1
    content = re.sub(r"versionCode\s+\d+", f"versionCode {new_code}", content)
    # versionName
    name_match = re.search(r"versionName\s+['\"]([^'\"]+)['\"]", content)
    if not name_match:
        raise RuntimeError("versionName not found in build.gradle")
    old_name = name_match.group(1)
    content = re.sub(r"versionName\s+['\"][^'\"]+['\"]", f"versionName \"{new_version}\"", content)
    write_file(gradle_path, content)
    print(f"Updated build.gradle: versionCode {old_code} → {new_code}, versionName {old_name} → {new_version}")
    return new_code

# ---------- 3️⃣ Update download.html ----------
def update_download_html(project_root: Path, new_version: str) -> None:
    # The download.html lives in the top‑level 'websites' directory, not inside the Flutter app folder.
    # First try the path relative to the detected project_root.
    html_path = project_root / "websites" / "bijbelquiz.app" / "download.html"
    if not html_path.exists():
        # Fallback: the project_root may be the 'app' subdirectory, so go one level up.
        html_path = project_root.parent / "websites" / "bijbelquiz.app" / "download.html"
    content = read_file(html_path)
    # Replace any occurrence like "Version: X.Y.Z" (case‑insensitive)
    new_content, count = re.subn(r"(Version[:\s]*)[0-9]+\.[0-9]+\.[0-9]+", f"\1{new_version}", content, flags=re.IGNORECASE)
    if count == 0:
        print("Warning: No version string found in download.html to replace.")
    write_file(html_path, new_content)
    print(f"Updated download.html (replaced {count} occurrence(s)).")

# ---------- 4️⃣ Build steps ----------
def flutter_build(project_root: Path) -> None:
    # Clean first
    run_cmd(["flutter", "clean"], cwd=project_root)
    run_cmd(["flutter", "pub", "get"], cwd=project_root)
    # Web
    run_cmd(["flutter", "build", "web", "--release"], cwd=project_root)
    # Android APK
    run_cmd(["flutter", "build", "apk", "--release"], cwd=project_root)
    # Android AAB
    run_cmd(["flutter", "build", "appbundle", "--release"], cwd=project_root)
    # Linux
    run_cmd(["flutter", "build", "linux", "--release"], cwd=project_root)

def copy_web_output(project_root: Path) -> None:
    src = project_root / "build" / "web"
    dest = project_root / "websites" / "play.bijbelquiz.app"
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    print(f"Copied web build from {src} to {dest}")

# ---------- Main ----------
def main() -> None:
    parser = argparse.ArgumentParser(description="Release automation for BijbelQuiz")
    parser.add_argument("version", help="New version string, e.g. 2.1.0")
    args = parser.parse_args()

    # Determine the Flutter project root (where pubspec.yaml lives)
    script_dir = Path(__file__).resolve().parent
    # The pubspec.yaml is inside the 'app' subdirectory of the repo.
    possible_app_root = script_dir / "app"
    if (possible_app_root / "pubspec.yaml").exists():
        project_root = possible_app_root
    else:
        project_root = find_flutter_root(script_dir)
    print(f"Detected Flutter project root: {project_root}")

    try:
        update_pubspec(project_root, args.version)
        new_code = update_build_gradle(project_root, args.version)
        update_download_html(project_root, args.version)
        flutter_build(project_root)
        copy_web_output(project_root)
        # Summarise artefacts
        apk = next(project_root.glob("build/app/outputs/apk/**/*.apk"), None)
        aab = next(project_root.glob("build/app/outputs/bundle/**/*.aab"), None)
        linux_bin = next((p for p in project_root.rglob("build/linux/**/release/*") if p.is_file() and os.access(p, os.X_OK)), None)
        print("\n=== Release Summary ===")
        print(f"Version: {args.version}")
        print(f"Android versionCode: {new_code}")
        print(f"Web output: {project_root / 'websites' / 'play.bijbelquiz.app'}")
        print(f"APK: {apk}")
        print(f"AAB: {aab}")
        print(f"Linux binary: {linux_bin}")
    except Exception as e:
        print(f"\n[ERROR] {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
