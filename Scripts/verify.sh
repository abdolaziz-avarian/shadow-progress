#!/bin/bash
# Build and test against an installed iPhone simulator without Apple signing credentials.
set -euo pipefail
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Resolve an available device instead of hard-coding a simulator UUID from one Mac.
SIMULATOR_ID="$(xcrun simctl list devices available -j | python3 -c 'import sys,json; devices=json.load(sys.stdin)["devices"]; print(next(d["udid"] for group in devices.values() for d in group if d["name"].startswith("iPhone")))')"
xcodebuild -project ShadowProgress.xcodeproj -scheme ShadowProgress \
    -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -derivedDataPath "${SHADOW_BUILD_DIR:-/tmp/ShadowProgressDerivedData}" \
    CODE_SIGNING_ALLOWED=NO test
