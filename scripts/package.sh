#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
zsh build.sh
app="$PWD/dist/Habibi-Pet-Bot.app"
version="$(cat VERSION)"
asset="Habibi-Pet-Bot-$version-universal.zip"
archive="$PWD/dist/$asset"
if [[ -n "${NOTARY_PROFILE:-}" ]]; then
  [[ -n "${SIGNING_IDENTITY:-}" ]] || { echo 'Set SIGNING_IDENTITY before notarizing.' >&2; exit 1; }
  ditto -c -k --keepParent "$app" dist/notarization.zip
  xcrun notarytool submit dist/notarization.zip --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$app"
  xcrun stapler validate "$app"
fi
stage="$(mktemp -d "$PWD/.build/package.XXXXXX")"
ditto "$app" "$stage/Habibi-Pet-Bot.app"
cp scripts/Install.command "$stage/Install.command"
cp docs/INSTALL.md "$stage/INSTALL.md"
chmod +x "$stage/Install.command"
ditto -c -k --keepParent "$stage/Habibi-Pet-Bot.app" "$archive"
# Add installer and instructions alongside the app at the root of the archive.
(cd "$stage" && /usr/bin/zip -q "$archive" Install.command INSTALL.md)
cp "$archive" dist/Habibi-Pet-Bot-universal.zip
(cd dist && shasum -a 256 "$asset" > SHA256SUMS.txt)
echo "Packaged: $PWD/dist/$asset"
if [[ -z "${NOTARY_PROFILE:-}" ]]; then
  echo 'Development package: not notarized. See docs/RELEASING.md for public distribution.'
fi
