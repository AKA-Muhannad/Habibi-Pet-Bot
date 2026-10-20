#!/bin/bash
# Native macOS installer. No sudo, Python, or Homebrew required.
set -euo pipefail

main() {
  local repo='AKA-Muhannad/Habibi-Pet-Bot'
  local version='latest' destination="$HOME/Applications" launch=1 source_build=0
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --version) [ "$#" -ge 2 ] || die '--version needs a value'; version="${2#v}"; shift 2 ;;
      --app-dir) [ "$#" -ge 2 ] || die '--app-dir needs a path'; destination="$2"; shift 2 ;;
      --no-open) launch=0; shift ;;
      --source) source_build=1; shift ;;
      --help|-h) printf '%s\n' 'Habibi-Pet-Bot installer (macOS 13+)' 'Usage: bash install.sh [--version 1.0.0] [--app-dir PATH] [--no-open] [--source]' 'Rerun to update. Installs in ~/Applications by default.'; return ;;
      *) die "Unknown option: $1" ;;
    esac
  done
  [ "$(uname -s)" = Darwin ] || die 'Habibi-Pet-Bot is a macOS desktop app. Linux, WSL, and Windows are not supported.'
  [ "$(id -u)" -ne 0 ] || die 'Run this as your normal user, without sudo.'
  local major
  major="$(sw_vers -productVersion)"; major="${major%%.*}"
  [ "$major" -ge 13 ] || die 'macOS 13 or later is required.'
  if [ "$version" != latest ] && ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then die 'Use a version such as 1.0.0.'; fi
  case "$destination" in /*) ;; *) die '--app-dir must be an absolute path.' ;; esac
  if pgrep -x HabibiPetBot >/dev/null 2>&1 || pgrep -x AssistantPet >/dev/null 2>&1; then
    die 'Your pet is running. Choose Quit in its paw menu, then run this command again.'
  fi
  habibi_scratch="$(mktemp -d "${TMPDIR:-/tmp}/habibi-install.XXXXXX")"
  trap 'rm -rf -- "$habibi_scratch"' EXIT
  local release_url="https://github.com/$repo/releases/latest/download" status asset app
  if [ "$version" != latest ]; then release_url="https://github.com/$repo/releases/download/v$version"; fi
  if [ "$source_build" -eq 0 ]; then
    printf '🐾 Finding your habibi…\n'
    status="$(curl --proto '=https' --tlsv1.2 -sSL --retry 2 -w '%{http_code}' "$release_url/SHA256SUMS.txt" -o "$habibi_scratch/SHA256SUMS.txt")" || die 'Could not reach GitHub. Check your connection.'
    if [ "$status" = 404 ] && [ "$version" = latest ]; then
      printf 'No published release yet. Building locally from source (Xcode command line tools required).\n'
      source_build=1
    elif [ "$status" != 200 ]; then die "Release unavailable (HTTP $status). Check the version or try later."; fi
  fi
  if [ "$source_build" -eq 1 ]; then
    xcrun --find swiftc >/dev/null 2>&1 || die 'Install Xcode command line tools with: xcode-select --install, then rerun.'
    local ref='heads/main'
    if [ "$version" != latest ]; then ref="tags/v$version"; fi
    curl --proto '=https' --tlsv1.2 -fsSL --retry 2 "https://github.com/$repo/archive/refs/$ref.tar.gz" -o "$habibi_scratch/source.tar.gz"
    mkdir "$habibi_scratch/source"
    tar -xzf "$habibi_scratch/source.tar.gz" -C "$habibi_scratch/source" --strip-components=1
    printf '🐾 Building your desktop sidekick…\n'
    /bin/zsh "$habibi_scratch/source/build.sh"
    app="$habibi_scratch/source/dist/Habibi-Pet-Bot.app"
  else
    local checksum
    checksum="$(awk 'NF == 2 && length($1) == 64 && $1 !~ /[^0-9a-fA-F]/ && $2 ~ /^Habibi-Pet-Bot-[0-9]+\.[0-9]+\.[0-9]+-universal\.zip$/ { print $1 }' "$habibi_scratch/SHA256SUMS.txt")"
    asset="$(awk 'NF == 2 && length($1) == 64 && $1 !~ /[^0-9a-fA-F]/ && $2 ~ /^Habibi-Pet-Bot-[0-9]+\.[0-9]+\.[0-9]+-universal\.zip$/ { print $2 }' "$habibi_scratch/SHA256SUMS.txt")"
    [ -n "$checksum" ] && [ "$(printf '%s\n' "$checksum" | wc -l | tr -d ' ')" = 1 ] || die 'Invalid release checksum manifest.'
    if [ "$version" != latest ] && [ "$asset" != "Habibi-Pet-Bot-$version-universal.zip" ]; then die 'Release version does not match the archive.'; fi
    curl --proto '=https' --tlsv1.2 -fsSL --retry 2 "$release_url/$asset" -o "$habibi_scratch/$asset"
    (cd "$habibi_scratch" && printf '%s  %s\n' "$checksum" "$asset" | shasum -a 256 -c -) || die 'Checksum verification failed. Nothing installed.'
    mkdir "$habibi_scratch/unpacked"
    ditto -x -k "$habibi_scratch/$asset" "$habibi_scratch/unpacked"
    app="$habibi_scratch/unpacked/Habibi-Pet-Bot.app"
  fi
  [ -d "$app" ] || die 'The download did not contain Habibi-Pet-Bot.app.'
  codesign --verify --strict "$app" || die 'App signature validation failed. Nothing installed.'
  [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist")" = 'local.assistantpet.mac' ] || die 'Unexpected application identity.'
  local target="$destination/Habibi-Pet-Bot.app" staging backup=''
  mkdir -p "$destination"
  staging="$(mktemp -d "$destination/.habibi-stage.XXXXXX")"
  ditto "$app" "$staging/Habibi-Pet-Bot.app" || { rm -rf -- "$staging"; die 'Could not copy app. Existing installation was kept.'; }
  codesign --verify --strict "$staging/Habibi-Pet-Bot.app" || { rm -rf -- "$staging"; die 'Staged app signature validation failed.'; }
  if [ -e "$target" ]; then
    mkdir -p "$HOME/.Trash"
    backup="$HOME/.Trash/Habibi-Pet-Bot-$(date +%s)-$$.app"
    mv "$target" "$backup" || { rm -rf -- "$staging"; die 'Could not back up your current pet.'; }
  fi
  if ! mv "$staging/Habibi-Pet-Bot.app" "$target"; then
    if [ -n "$backup" ]; then mv "$backup" "$target"; fi
    rm -rf -- "$staging"; die 'Installation failed; the previous installation was restored.'
  fi
  rmdir "$staging"
  printf '🐾 Habibi is home! Installed: %s\n' "$target"
  printf 'Rerun this installer to update. Your pet and preferences are kept.\n'
  if [ "$launch" -eq 1 ]; then open "$target"; fi
}
die() { printf 'Habibi-Pet-Bot: %s\n' "$*" >&2; exit 1; }
main "$@"
