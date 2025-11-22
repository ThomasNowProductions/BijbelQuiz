#!/usr/bin/env python3
"""Release helper script for BijbelQuiz (now located in scripts/).

Usage:
    python3 scripts/update_release.py <new_version>

The script will:
  1. Update `app/pubspec.yaml` with the new version and increment the build number.
  2. Increment Android `versionCode` and set `versionName` in `app/android/app/build.gradle`.
  3. Replace the version string in `websites/bijbelquiz.app/download.html`.
  4. Build Flutter artefacts (web, APK, AAB, Linux).
  5. Copy the generated web build into `websites/play.bijbelquiz.app`.
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

# ---------- Paths based on script location ----------
# The script lives in <repo_root>/scripts/, so the repo root is its parent.
REPO_ROOT = Path(__file__).resolve().parent.parent
APP_ROOT = REPO_ROOT / "app"
WEB_ROOT = REPO_ROOT / "websites"

# ---------- 1️⃣ Update pubspec.yaml (bump version & build number) ----------

def update_pubspec(new_version: str) -> None:
    pubspec_path = APP_ROOT / "pubspec.yaml"
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

def update_build_gradle(new_version: str) -> int:
    gradle_path = APP_ROOT / "android" / "app" / "build.gradle"
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

def update_download_html(new_version: str) -> None:
    html_path = WEB_ROOT / "bijbelquiz.app" / "download.html"
    if not html_path.exists():
        raise RuntimeError(f"download.html not found at {html_path}")
    content = read_file(html_path)
    new_content, count = re.subn(r"(Version[:\s]*)[0-9]+\.[0-9]+\.[0-9]+", f"\1{new_version}", content, flags=re.IGNORECASE)
    if count == 0:
        print("Warning: No version string found in download.html to replace.")
    write_file(html_path, new_content)
    print(f"Updated download.html (replaced {count} occurrence(s)).")

# ---------- 4️⃣ Build steps ----------

def flutter_build() -> None:
    # Clean first
    run_cmd(["flutter", "clean"], cwd=APP_ROOT)
    run_cmd(["flutter", "pub", "get"], cwd=APP_ROOT)
    # Web
    run_cmd(["flutter", "build", "web", "--release"], cwd=APP_ROOT)
    # Android APK
    run_cmd(["flutter", "build", "apk", "--release"], cwd=APP_ROOT)
    # Android AAB
    run_cmd(["flutter", "build", "appbundle", "--release"], cwd=APP_ROOT)
    # Linux
    run_cmd(["flutter", "build", "linux", "--release"], cwd=APP_ROOT)

def copy_web_output() -> None:
    src = APP_ROOT / "build" / "web"
    dest = WEB_ROOT / "play.bijbelquiz.app"
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    print(f"Copied web build from {src} to {dest}")

# ---------- Main ----------
def main() -> None:
    parser = argparse.ArgumentParser(description="Release automation for BijbelQuiz (scripts version)")
    parser.add_argument("version", help="New version string, e.g. 2.1.0")
    args = parser.parse_args()

    try:
        update_pubspec(args.version)
        new_code = update_build_gradle(args.version)
        update_download_html(args.version)
        flutter_build()
        copy_web_output()
        # Summarise artefacts
        apk = next(APP_ROOT.glob("build/app/outputs/apk/**/*.apk"), None)
        aab = next(APP_ROOT.glob("build/app/outputs/bundle/**/*.aab"), None)
        linux_bin = next((p for p in APP_ROOT.rglob("build/linux/**/release/*") if p.is_file() and os.access(p, os.X_OK)), None)
        print("\n=== Release Summary ===")
        print(f"Version: {args.version}")
        print(f"Android versionCode: {new_code}")
        print(f"Web output: {WEB_ROOT / 'play.bijbelquiz.app'}")
        print(f"APK: {apk}")
        print(f"AAB: {aab}")
        print(f"Linux binary: {linux_bin}")
    except Exception as e:
        print(f"\n[ERROR] {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
