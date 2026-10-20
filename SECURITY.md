# Security and privacy

To report a security issue, use the repository's private vulnerability reporting feature if enabled. Do not include credentials or private prompts in public issues. If private reporting is not enabled, ask the maintainer for a private channel without disclosing the vulnerability publicly.

Habibi-Pet-Bot does not send prompts to an AI provider itself and does not collect analytics. Claude Code and Siri use their own accounts and settings. Claude event labels, tool names, and the first 100 characters of the current prompt are stored in a private temporary session directory for the activity pill. Tool arguments and assistant responses are not stored. These temporary files may remain until macOS clears them. Preferences live in the app's UserDefaults domain.

The pet's Claude hooks are scoped to sessions it launches. They do not grant new tool permissions. Update checks send an HTTPS request to GitHub only when requested; GitHub sees ordinary connection information such as IP address. Update installation is manual. Review the release's signing status before installing.
