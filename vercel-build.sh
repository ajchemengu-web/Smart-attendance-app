#!/usr/bin/env bash
# Vercel has no native Flutter builder, so this script fetches the SDK
# itself before building — invoked as this project's Vercel buildCommand
# (see vercel.json). Pinned to the same version the sandbox verified
# this repo against (pubspec.yaml's `sdk: ^3.13.3`), rather than
# `channel: stable` like the GitHub Pages workflow uses, since a build
# platform with no persistent cache should not silently pick up a newer
# SDK mid-deploy.
set -euo pipefail

FLUTTER_VERSION="3.47.5"
FLUTTER_HOME="/tmp/flutter-sdk"

if [ ! -d "$FLUTTER_HOME" ]; then
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -o /tmp/flutter.tar.xz
  mkdir -p "$FLUTTER_HOME"
  tar -xf /tmp/flutter.tar.xz -C "$FLUTTER_HOME" --strip-components=1
  rm /tmp/flutter.tar.xz
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

# The extracted SDK's UID can differ from the build process's, which
# git treats as "dubious ownership" and refuses to touch — confirmed
# reproducing this exact failure in a sandbox build before adding this.
git config --global --add safe.directory "$FLUTTER_HOME"

flutter config --no-analytics --no-cli-animations
flutter pub get

# API_BASE_URL is a Vercel project environment variable (Project
# Settings > Environment Variables) — same convention as the repo
# Actions variable the GitHub Pages/APK workflows use. See lib/config.dart.
# No --base-href override here (unlike the GitHub Pages build): a
# Vercel deployment is served from its domain root, not a /repo-name/
# subpath.
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"
