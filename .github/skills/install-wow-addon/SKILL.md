---
name: install-wow-addon
description: "Install or update this World of Warcraft addon in a local WoW instance. Use when asked to add, deploy, copy, or test the addon under the World of Warcraft installation directory."
argument-hint: "Optional WoW installation root or flavor folder, such as _retail_"
---

# Install WoW Addon

Install the current addon package into a local World of Warcraft client without copying repository metadata.

## Procedure

1. Confirm the addon TOC exists in the workspace and read its `## Interface` value.
2. Use the default installation root `C:\Program Files (x86)\World of Warcraft` unless the user provides another path.
3. Use `_retail_` as the default flavor because this addon targets interface `120100`. Accept an explicit flavor such as `_classic_era_` only when it is compatible with the TOC interface.
4. Ask the user to close the WoW client before installation if it is running.
5. Run [install-wow-addon.ps1](./scripts/install-wow-addon.ps1) with `-WhatIf` first when the destination or file set is uncertain.
6. Run the script without `-WhatIf` to copy the TOC and only the source files listed by it into `<flavor>\Interface\AddOns\<addon-folder>`.
7. Confirm the destination contains the TOC and every manifest file, then report the exact installed path.
8. Have the user enable or reload the addon in WoW and verify the load message and the absence of Lua errors. This addon scaffold does not currently define a project-specific `/wptest` slash command; the initialization message and default chat log are the relevant verification points.

## Safety and Failure Handling

- Do not copy `.github`, `.vscode`, `.git`, README files, or unrelated workspace files into the game directory.
- Do not overwrite a different addon folder when the TOC name and destination folder do not match.
- If the installation directory is missing or access is denied, stop and report the path and the required permission change; do not attempt elevation automatically.
- If no WoW client is available, report that installation was not verified in-game.