#!/usr/bin/env bash
# Build the Quest 3S APK for Toffoli Troubles.
set -euo pipefail

GODOT="${GODOT:-$HOME/Godot/Godot_v4.7.2-stable_linux.x86_64}"
PRESET="${PRESET:-Android}"
OUT="${OUT:-$HOME/toffoli_troubles.apk}"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
INSTALL="${INSTALL:-0}"

fail() { echo "ERROR: $*" >&2; exit 1; }

[ -x "$GODOT" ] || fail "Godot binary not found at $GODOT (set GODOT=...)"
[ -x "$JAVA_HOME/bin/java" ] || fail "JDK 17 not found at $JAVA_HOME (set JAVA_HOME=...)"
[ -d "$ANDROID_HOME" ] || fail "Android SDK not found at $ANDROID_HOME (set ANDROID_HOME=...)"
[ -d "$ANDROID_HOME/build-tools" ] || fail "build-tools missing; run: sdkmanager \"build-tools;34.0.0\""
[ -d "$ANDROID_HOME/platforms" ] || fail "platforms missing; run: sdkmanager \"platforms;android-35\""
[ -d "$HOME/.local/share/godot/export_templates/4.7.2.stable" ] || fail "Godot 4.7.2 export templates missing"
[ -f export_presets.cfg ] || fail "export_presets.cfg missing; create the Android preset in the editor"
command -v adb >/dev/null 2>&1 || fail "adb not found (install android-platform-tools)"

export JAVA_HOME
export ANDROID_HOME
export PATH="$JAVA_HOME/bin:$PATH"

echo "Exporting preset '$PRESET' -> $OUT"
"$GODOT" --headless --export-debug "$PRESET" "$OUT"

if [ "$INSTALL" = "1" ]; then
  echo "Devices:"
  adb devices
  adb install -r "$OUT"
fi

echo "Done: $OUT"
