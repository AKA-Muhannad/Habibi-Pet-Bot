# Install Habibi-Pet-Bot

Requires macOS 13 or later. The universal app supports Apple Silicon and Intel. Apple Intelligence features require Apple's compatible hardware, macOS version, language, and enabled settings. Claude Code must be installed and signed in separately.

## Native install (recommended)

```sh
curl -fsSL https://raw.githubusercontent.com/AKA-Muhannad/Habibi-Pet-Bot/main/install.sh | bash
```

Installs in `~/Applications`, verifies the release checksum and app signature, and opens the pet. Quit any running pet first. Rerun the command to update. If there is no published release, it builds from main using Xcode command line tools. To request a source build explicitly, or choose an exact release:

```sh
curl -fsSL https://raw.githubusercontent.com/AKA-Muhannad/Habibi-Pet-Bot/main/install.sh -o /tmp/habibi-install.sh
bash /tmp/habibi-install.sh --source
bash /tmp/habibi-install.sh --version 1.0.0
```

You can inspect the downloaded script before running it. Options: `--app-dir /absolute/path`, `--no-open`, `--version X.Y.Z`, `--source`, and `--help`. No sudo. Existing apps are staged and verified before replacement; the previous app is moved to Trash. Preferences remain saved. Do not mix install methods: update a Homebrew installation through Homebrew.

## Homebrew

```sh
brew tap aka-muhannad/habibi-pet-bot https://github.com/AKA-Muhannad/Habibi-Pet-Bot.git
brew install --cask aka-muhannad/habibi-pet-bot/habibi-pet-bot
```

The cask requires a published release with the stable-name `Habibi-Pet-Bot-universal.zip` asset. It uses `version :latest`, so update explicitly with:

```sh
brew update
brew reinstall --cask aka-muhannad/habibi-pet-bot/habibi-pet-bot
```

The mutable latest-release asset uses Homebrew's `sha256 :no_check`. Use the native installer if you want the release manifest checksum verified. Homebrew and macOS keep their normal verification and quarantine behavior.

Linux, WSL, Windows, and WinGet are not supported by this native macOS app.

## Manual download

1. Download `Habibi-Pet-Bot-VERSION-universal.zip` from this project's GitHub Releases page.
2. Extract the ZIP by double-clicking it.
3. Move `Habibi-Pet-Bot.app` to Applications. Alternatively, run the included `Install.command` to install in `~/Applications` without administrator access. The installer asks before replacing a previous version and moves it to Trash.
4. Open Habibi-Pet-Bot. Use the paw in the menu bar if you cannot see it.

The app's first open depends on the release's signing status. Development builds are ad-hoc signed and not notarized. Use a notarized release for normal public distribution, or build from source locally. Do not disable Gatekeeper or remove quarantine attributes.

## Use it

- Click the pet to show/hide activity. Drag it to move it; right-click for settings.
- Terminal button: pick a folder and start a connected Claude Code session.
- Sparkles: open Siri. Configure a custom Apple Intelligence shortcut from the menu if desired.
- Paw button: choose from 10 pixel pets.
- Activity arrow: return to the assistant. Pause: pause activity updates only.

## Update

Choose **Check for updates…** from the menu bar paw or pet's right-click menu. GitHub release builds know their repository automatically. Source builds can set it using **Set GitHub repository…**.

If a newer stable version exists, click **Open download page**, download and extract it, quit Habibi-Pet-Bot, then replace the installed app (or run the new `Install.command`). Start the new version. Pet choice, position, project folder, and shortcut preferences remain saved.

Checks happen only when requested. Updates are not installed automatically. Private repositories and prerelease updates are not supported by the in-app checker.

## Verify a download

Download `SHA256SUMS.txt` beside the release ZIP. In Terminal, change to that download folder and run:

```sh
shasum -a 256 -c SHA256SUMS.txt
```

Checksums detect corrupt downloads; they do not replace Apple's Developer ID verification.

## Uninstall

Quit from the paw menu, then move Habibi-Pet-Bot.app to Trash. Saved preferences remain so reinstalling restores your pet. To remove them too, run `defaults delete local.assistantpet.mac` in Terminal after quitting.
