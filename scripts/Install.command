#!/bin/zsh
set -eu
cd "$(dirname "$0")"
app="$PWD/Habibi-Pet-Bot.app"
destination="$HOME/Applications"
if [[ ! -d "$app" ]]; then
  echo 'Keep Install.command beside Habibi-Pet-Bot.app after extracting the release ZIP.' >&2
  exit 1
fi
codesign --verify --strict "$app"
echo 'Habibi-Pet-Bot will be installed in ~/Applications.'
echo 'For updates, quit Habibi-Pet-Bot using its paw menu before continuing.'
printf 'Install or replace Habibi-Pet-Bot? [y/N] '
read -r answer
[[ "$answer" == [yY] ]] || exit 0
if pgrep -x HabibiPetBot >/dev/null; then
  echo 'Habibi-Pet-Bot is still running. Quit it, then run this installer again.' >&2
  exit 1
fi
mkdir -p "$destination"
if [[ -e "$destination/Habibi-Pet-Bot.app" ]]; then
  mkdir -p "$HOME/.Trash"
  mv "$destination/Habibi-Pet-Bot.app" "$HOME/.Trash/Habibi-Pet-Bot-$(date +%s)-$$.app"
fi
ditto "$app" "$destination/Habibi-Pet-Bot.app"
codesign --verify --strict "$destination/Habibi-Pet-Bot.app"
echo "Installed in $destination/Habibi-Pet-Bot.app. Your pet and preferences are preserved."
open "$destination/Habibi-Pet-Bot.app"
