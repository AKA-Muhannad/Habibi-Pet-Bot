# Habibi-Pet-Bot 🐾

Your little habibi for big ideas. A native macOS desktop pet for Claude Code and Apple Intelligence.

[Download releases](https://github.com/AKA-Muhannad/Habibi-Pet-Bot/releases) · [Installation guide](docs/INSTALL.md) · [Release guide](docs/RELEASING.md)

## Meet your sidekick

- **10 pixel pets:** Cloud cat, Ember fox, Moon bunny, Honey bear, Bamboo panda, Mochi frog, Pip penguin, Bolt robot, Sprout dragon, and Cocoa owl.
- **A floating companion:** drag it around, take it across Spaces, and choose a new friend from the gallery.
- **Claude Code activity:** a compact pill shows your task, tool use, approval requests, and completion for sessions opened through the pet.
- **Pick your project:** choose a folder each time you launch Claude Code; your last location is remembered.
- **Apple Intelligence:** open Siri or run a named shortcut you create in Apple's Shortcuts app.
- **Manual update checks:** the paw menu checks this repository's latest published stable release when you ask.

No API keys, third-party runtime dependencies, or analytics. Uses native AppKit and respects Reduce Motion.

## Install

Requires **macOS 13 or later**, on Apple Silicon or Intel. Apple Intelligence needs a compatible Mac and macOS version with the feature enabled. Claude Code must be installed and authenticated separately.

1. Open [Releases](https://github.com/AKA-Muhannad/Habibi-Pet-Bot/releases). If no release is published yet, use the source-build steps below.
2. Download and extract `Habibi-Pet-Bot-VERSION-universal.zip`.
3. Move `Habibi-Pet-Bot.app` to Applications, or run the included `Install.command` to install in `~/Applications`.
4. Open the app. A little pet and toolbar appear near the bottom-right of your desktop.

Automated builds are **ad-hoc signed and not notarized**. See each release's notes for its signing status. For normal public distribution, the maintainer must sign with Developer ID and notarize it. You can build locally from source without a Developer ID. See the [installation guide](docs/INSTALL.md).

## Use

| Control | What it does |
| --- | --- |
| Click the pet | Show or hide activity |
| Drag the pet | Move your sidekick |
| Right-click or menu-bar paw | Settings, update checks, and quit |
| Terminal button | Choose a folder and start Claude Code |
| Sparkles button | Open Siri |
| Paw button | Preview and choose from 10 pets |
| Activity return arrow | Open the assistant's app |
| Activity pause button | Pause popup updates; the assistant keeps running |

For a custom Apple Intelligence shortcut, create **Ask for Input → Use Model → Show Result** in Shortcuts and save its exact name through the pet menu. [Apple's guide](https://support.apple.com/guide/shortcuts-mac/use-apple-intelligence-in-shortcuts-mchl91750563/mac) describes supported models and requirements.

Claude Code uses your existing installation and account. The pet launches an interactive `claude` session with session-scoped activity hooks. Existing sessions are not connected. Siri does not expose a live activity feed to the pet. [Claude Code CLI reference](https://code.claude.com/docs/en/cli-reference).

## Update

Choose **Check for updates…** in the paw menu. If a newer version is available, open its download page, quit the old pet, and replace the app using the ZIP or installer. Your preferences stay saved. Updates are manual; nothing installs in the background.

## Build from source

Install Xcode command line tools, then:

```sh
git clone https://github.com/AKA-Muhannad/Habibi-Pet-Bot.git
cd Habibi-Pet-Bot
zsh build.sh
open dist/Habibi-Pet-Bot.app
```

Builds a universal app for Apple Silicon and Intel. Local builds use ad-hoc signing. To test or create an installable ZIP:

```sh
python3 -m unittest discover -s tests -v
zsh scripts/package.sh
```

Output: `dist/Habibi-Pet-Bot-1.0.0-universal.zip` and `dist/SHA256SUMS.txt` (version follows `VERSION`).

## Publish a new version

Update `VERSION`, the changelog, and release notes; commit; then push a matching `v1.0.1` tag. GitHub Actions builds, tests, and prepares a **draft** release with the ZIP and checksums. Review signing status and assets before publishing. See [RELEASING.md](docs/RELEASING.md) for notarization and full instructions.

## Privacy and limits

Task event labels, tool names, and the first 100 characters of the current prompt are stored in a private temporary directory for the activity pill. Tool arguments and assistant responses are not retained. Only the most recently launched Claude session is displayed. Settings remain local. Update checks contact GitHub only when requested. See [SECURITY.md](SECURITY.md).

Independent project; not affiliated with OpenAI, Anthropic, or Apple. Original pixel artwork. [MIT license](LICENSE).
