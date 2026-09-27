---
name: uninstall-wow-addon
description: "Remove this World of Warcraft addon from a local WoW installation directory. Use when asked to uninstall, delete, or clean an addon from the game client."
argument-hint: "Optional WoW installation root or flavor folder, such as _retail_"
---

# Uninstall WoW Addon

Remove the current addon package from a local World of Warcraft client without deleting unrelated workspace files.

## Procedure

1. Confirm the addon TOC exists in the workspace and read its `## Title` and filename values.
2. Use the default installation root `C:\Program Files (x86)\World of Warcraft` unless the user provides another path.
3. Use `_retail_` as the default flavor because this addon targets interface `120100`. Accept an explicit flavor such as `_classic_era_` only when it is compatible with the TOC interface.
4. Ask the user to close the WoW client before removal if it is running.
5. Run [uninstall-wow-addon.ps1](./scripts/uninstall-wow-addon.ps1) with `-WhatIf` first when the destination or file set is uncertain.
6. Run the script without `-WhatIf` to delete the addon folder under `<flavor>\Interface\AddOns\<addon-folder>`.
7. Confirm the target folder is removed or empty and report the exact uninstall path.
8. Have the user reload the addon list in WoW and verify that the addon no longer appears in the AddOns list.

## Safety and Failure Handling

- Do not remove the repository root or any files outside the destination addon folder.
- Only delete the exact addon directory derived from the TOC basename; do not remove a different folder with a similar name.
- If the installation directory is missing or access is denied, stop and report the path and the required permission change; do not attempt elevation automatically.
- If the addon is not installed at the expected path, report that clearly and ask whether the user wants a different flavor or installation root.
- If no WoW client is available, report that removal was not verified in-game.
