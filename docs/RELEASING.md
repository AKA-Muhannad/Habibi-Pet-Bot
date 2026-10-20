# Publish and maintain releases

## First GitHub upload

Create an empty GitHub repository, then run in this project directory, replacing AKA-Muhannad/Habibi-Pet-Bot with its actual name:

```sh
git remote add origin https://github.com/AKA-Muhannad/Habibi-Pet-Bot.git
git push -u origin main
```

This repository includes CI, release automation, installation documentation, and MIT licensing. Do not commit `dist/`, signing certificates, passwords, or private keys.

## Prepare a version

1. Update `VERSION` (three numeric components, such as `1.0.1`) and `CHANGELOG.md`.
2. Update `docs/RELEASE-NOTES.md` for that version, including signing status.
3. Commit and push the changes.
4. Tag that exact version:

```sh
git tag v1.0.1
git push origin v1.0.1
```

The tag workflow checks that it matches VERSION, builds a universal app, runs tests, packages a ZIP with an optional local installer, produces SHA-256 checksums, and creates a **draft** GitHub release. GitHub-hosted runners provide `gh` and Python. The repository needs GitHub Actions enabled and permission to create releases. Review the draft before publishing; only published stable releases are found by the app's update checker.

CI-generated builds are ad-hoc signed. Apple Developer credentials are deliberately not required by CI. For normal public distribution, create a signed and notarized package locally and replace the draft assets before publishing.

## Developer ID signing and notarization

Prerequisites: Apple Developer Program membership, a Developer ID Application certificate with its private key in your local keychain, and `notarytool` credentials stored in a keychain profile. Configure these using Apple's documentation; do not put credentials in source files or shell history.

```sh
export GITHUB_REPOSITORY=AKA-Muhannad/Habibi-Pet-Bot
export SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)'
export NOTARY_PROFILE='habibi-pet-bot-notary'
zsh scripts/package.sh
```

The build enables hardened runtime and timestamps the Developer ID signature. Packaging submits the app to Apple, waits for acceptance, staples the notarization ticket, validates it, then creates the final ZIP and checksums. Submission failure stops packaging. Keep NOTARY_PROFILE unset for local development packages.

Replace both the ZIP and checksum file in the draft release using GitHub's release editor. If using an authenticated GitHub CLI:

```sh
gh release upload v1.0.1 dist/Habibi-Pet-Bot-1.0.1-universal.zip dist/Habibi-Pet-Bot-universal.zip dist/SHA256SUMS.txt install.sh --clobber
```

Verify the downloaded ZIP and smoke-test on a separate Mac before publishing the draft. Check pet selection, dragging, hide/show, Siri opening, Claude folder selection, activity events, and update checks. Intel binaries are cross-compiled and need runtime verification on Intel hardware.

Apple reference: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution

## Updates

The app stores its version in Info.plist and repository in HabibiPetBotRepository. GitHub Actions provides GITHUB_REPOSITORY during builds; pass it explicitly for local builds intended for release. A user override is available in the app menu. No credentials are sent by the update checker. It contacts GitHub's public latest-release endpoint only on request, compares numeric stable versions, and offers the canonical GitHub release page. It does not download or execute update code.

To withdraw a bad release, make it a draft again and publish a higher patch version. Installed preferences are kept during replacement. Do not reuse a published tag for different source code.

## CLI and Homebrew distribution

`install.sh` on main is the native bootstrap endpoint. It supports a version-pinned install and defaults to the latest stable release. Before the first public release, it falls back to a local source build. Never remove quarantine or disable Gatekeeper in this script.

Every package includes the versioned ZIP plus an identical stable-name alias, `Habibi-Pet-Bot-universal.zip`, for the Homebrew cask in `Casks/`. The draft release workflow uploads both ZIPs, SHA256SUMS.txt, and install.sh. When replacing assets with notarized builds, upload both ZIP names and the checksum manifest together. The checksum manifest names the versioned ZIP.

The project itself can be tapped with an explicit Git URL; a separate homebrew-* repository is not required. The cask intentionally uses the mutable latest-release URL with `version :latest` and `sha256 :no_check`; users update with `brew reinstall`. Native installation instead validates the versioned ZIP against the release checksum manifest. Neither method can download a draft or private release. Publish the reviewed draft to enable binary installation.
