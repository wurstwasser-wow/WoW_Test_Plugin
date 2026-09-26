---
name: World of Warcraft Addon Files
description: "Use when creating or modifying World of Warcraft addon Lua, TOC, or XML files. Covers API compatibility, load order, scope, and client validation."
applyTo: "**/*.{lua,toc,xml}"
---

# World of Warcraft Addon Files

- Inspect neighboring addon files and the applicable `.toc` file before introducing a new pattern.
- Keep Blizzard API usage compatible with the project’s declared interface version and verify uncertain API behavior against current addon documentation or in-game testing.
- Keep globals intentional; prefer local scope unless the addon’s public event or slash-command surface requires a global.
- When adding or renaming a file, update the relevant `.toc` load order and references.
- Preserve existing addon conventions for event registration, frame creation, naming, and localization once those conventions are established.
- Avoid adding external dependencies unless the project already uses them and their loading order is explicit.
- Validate behavior in the WoW client or with the project’s documented test command when one exists.