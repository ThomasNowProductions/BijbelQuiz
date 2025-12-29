#!/usr/bin/env python3
"""Release helper script for BijbelQuiz (now located in scripts/).

Usage:
    python3 scripts/update_release.py <new_version> [--platform web|apk|aab|linux]

The script will:
  1. Update `app/pubspec.yaml` with the new version and increment the build number.
  2. Increment Android `versionCode` and set `versionName` in `app/android/app/build.gradle`.
  3. Replace the version string in `websites/bijbelquiz.app/download.html`.
  4. Build Flutter artefacts (web, APK, AAB, Linux) - specify --platform to build only one.
  5. Package the Linux binary in a .tar.gz archive and place it in the root directory (if building for Linux).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tarfile
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
WEB_ROOT = REPO_ROOT / "website"

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
    html_path = WEB_ROOT / "download.html"
    if not html_path.exists():
        raise RuntimeError(f"download.html not found at {html_path}")
    content = read_file(html_path)
    new_content, count = re.subn(r"(Version[:\s]*)[0-9]+\.[0-9]+\.[0-9]+", f"\1{new_version}", content, flags=re.IGNORECASE)
    if count == 0:
        print("Warning: No version string found in download.html to replace.")
    write_file(html_path, new_content)
    print(f"Updated download.html (replaced {count} occurrence(s)).")

# ---------- 4️⃣ Build steps ----------

def flutter_build(platform: str | None = None) -> None:
    # Clean first
    run_cmd(["flutter", "clean"], cwd=APP_ROOT)
    run_cmd(["flutter", "pub", "get"], cwd=APP_ROOT)

    if platform is None or platform == "web":
        # Web
        run_cmd(["flutter", "build", "web", "--release"], cwd=APP_ROOT)

    if platform is None or platform == "apk":
        # Android APK
        run_cmd(["flutter", "build", "apk", "--release"], cwd=APP_ROOT)

    if platform is None or platform == "aab":
        # Android AAB
        run_cmd(["flutter", "build", "appbundle", "--release"], cwd=APP_ROOT)

    if platform is None or platform == "linux":
        # Linux
        run_cmd(["flutter", "build", "linux", "--release"], cwd=APP_ROOT)

def package_linux_binary(version: str) -> None:
    """Package the Linux binary in a .tar.gz archive and place it in the root directory."""
    # Check for both possible directory structures
    linux_build_dirs = [
        APP_ROOT / "build" / "linux" / "x64" / "bundle",
        APP_ROOT / "build" / "linux" / "x64" / "release" / "bundle"
    ]

    linux_build_dir = None
    for possible_dir in linux_build_dirs:
        if possible_dir.exists():
            linux_build_dir = possible_dir
            break

    if linux_build_dir is None:
        print(f"Warning: Linux build directory not found in any of: {linux_build_dirs}")
        return

    # Find the executable binary in the bundle
    app_executable = None
    for item in linux_build_dir.iterdir():
        if item.is_file() and os.access(item, os.X_OK):
            app_executable = item
            break

    if not app_executable:
        print(f"Warning: No executable found in {linux_build_dir}")
        return

    # Create the archive name
    archive_name = f"bijbelquiz-{version}-linux-x64.tar.gz"
    archive_path = REPO_ROOT / archive_name

    # Create the .tar.gz archive
    with tarfile.open(archive_path, "w:gz") as tar:
        # Add the entire bundle directory to the archive
        tar.add(str(linux_build_dir), arcname=os.path.basename(str(linux_build_dir)))

    print(f"Created Linux binary archive: {archive_path}")

# ---------- Main ----------
def main() -> None:
    parser = argparse.ArgumentParser(description="Release automation for BijbelQuiz (scripts version)")
    parser.add_argument("version", help="New version string, e.g. 2.1.0")
    parser.add_argument("--platform", choices=["web", "apk", "aab", "linux"], help="Build only for a specific platform")
    args = parser.parse_args()

    try:
        update_pubspec(args.version)
        new_code = update_build_gradle(args.version)
        update_download_html(args.version)
        flutter_build(platform=args.platform)

        # Package Linux binary only if building specifically for Linux or all platforms
        if args.platform is None or args.platform == "linux":
            package_linux_binary(args.version)

        # Summarise artefacts
        apk = next(APP_ROOT.glob("build/app/outputs/apk/**/*.apk"), None)
        aab = next(APP_ROOT.glob("build/app/outputs/bundle/**/*.aab"), None)
        linux_bin = next((p for p in APP_ROOT.rglob("build/linux/**/release/*") if p.is_file() and os.access(p, os.X_OK)), None)
        linux_archive = REPO_ROOT / f"bijbelquiz-{args.version}-linux-x64.tar.gz"
        web_output = APP_ROOT / "build" / "web"
        print("\n=== Release Summary ===")
        print(f"Version: {args.version}")
        print(f"Android versionCode: {new_code}")
        if args.platform is None or args.platform == "web":
            print(f"Web output: {web_output}")
        if args.platform is None or args.platform == "apk":
            print(f"APK: {apk}")
        if args.platform is None or args.platform == "aab":
            print(f"AAB: {aab}")
        if args.platform is None or args.platform == "linux":
            print(f"Linux binary: {linux_bin}")
            print(f"Linux archive: {linux_archive}")
    except Exception as e:
        print(f"\n[ERROR] {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
