#!/bin/zsh
# Captures the App Store screenshots from a Debug build on two simulators:
#   6.9-inch: iPhone 17 Pro Max (1320 × 2868) → AppStore/screenshots/
#   6.5-inch: iPhone 14 Plus    (1284 × 2778) → AppStore/screenshots-6.5/
# Usage: scripts/screenshots.sh   (from the repo root; builds first)
set -euo pipefail

ROOT=${0:A:h:h}
BUNDLE=com.eliasnemr.padelboard
DERIVED=${TMPDIR:-/tmp}/padelboard-screenshots-dd
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-0

# name|launch arguments
SHOTS=(
  "01-doubles|-fresh -court doubles -step 1"
  "02-approach|-fresh -court doubles -step 2"
  "03-own-the-net|-fresh -court doubles -step 3"
  "04-singles|-fresh -court singles -step 2"
)

# Derived data lives outside ~/Documents: code signing rejects the Finder metadata there.
xcodebuild -project "$ROOT/PadelBoard.xcodeproj" -scheme PadelBoard -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DERIVED" -quiet build
APP="$DERIVED/Build/Products/Debug-iphonesimulator/PadelBoard.app"

capture() {
  local device_name=$1 device_type=$2 out_dir=$3
  local udid
  udid=$(xcrun simctl list devices available | grep "PadelBoard $device_name (" | head -1 | grep -oE '[0-9A-F-]{36}' || true)
  if [[ -z $udid ]]; then
    udid=$(xcrun simctl create "PadelBoard $device_name" "$device_type" "$RUNTIME")
  fi
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl status_bar "$udid" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
  xcrun simctl ui "$udid" appearance light
  xcrun simctl install "$udid" "$APP"
  mkdir -p "$out_dir"
  for shot in $SHOTS; do
    local name=${shot%%|*} args=${shot#*|}
    xcrun simctl terminate "$udid" "$BUNDLE" 2>/dev/null || true
    xcrun simctl launch "$udid" "$BUNDLE" ${=args} >/dev/null
    sleep 3
    xcrun simctl io "$udid" screenshot --type=png "$out_dir/$name.png" >/dev/null 2>&1
    echo "$device_name: $out_dir/$name.png"
  done
}

capture "6.9" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max "$ROOT/AppStore/screenshots"
capture "6.5" com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus "$ROOT/AppStore/screenshots-6.5"
