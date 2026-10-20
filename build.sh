#!/bin/zsh
set -eu
cd "$(dirname "$0")"
APP="$PWD/dist/Habibi-Pet-Bot.app"
version="$(cat VERSION)"
[[ "$version" =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || { echo 'VERSION must use major.minor.patch' >&2; exit 1; }
mkdir -p "$APP/Contents/MacOS" .build/module-cache
sdk="$(xcrun --sdk macosx --show-sdk-path)"
for architecture in arm64 x86_64; do
  xcrun swiftc -O -sdk "$sdk" -target "${architecture}-apple-macosx13.0" -module-cache-path "$PWD/.build/module-cache" Sources/main.swift -o ".build/HabibiPetBot-$architecture" -framework AppKit
done
lipo -create .build/HabibiPetBot-arm64 .build/HabibiPetBot-x86_64 -output "$APP/Contents/MacOS/HabibiPetBot"
cp Info.plist "$APP/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "$version" "$APP/Contents/Info.plist"
plutil -replace CFBundleVersion -string "${BUILD_NUMBER:-1}" "$APP/Contents/Info.plist"
plutil -replace HabibiPetBotRepository -string "${GITHUB_REPOSITORY:-AKA-Muhannad/Habibi-Pet-Bot}" "$APP/Contents/Info.plist"
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP"
else
  codesign --force --sign - "$APP"
fi
codesign --verify --strict "$APP"
echo "Built: $APP"
