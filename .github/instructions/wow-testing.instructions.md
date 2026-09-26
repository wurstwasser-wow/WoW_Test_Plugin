---
name: World of Warcraft In-Game Testing
description: "Use when validating World of Warcraft addon changes, diagnosing Lua errors, checking UI behavior, or preparing an in-game test plan."
applyTo: "**/*.{lua,toc,xml}"
---

# World of Warcraft In-Game Testing

- Identify the changed behavior and the WoW lifecycle or gameplay state that can expose it before testing.
- Test the smallest relevant path first, then cover reload, login, combat lockdown, zone changes, and missing-data cases when applicable.
- Check the default chat frame and error reporting for Lua errors, taint warnings, missing files, and dependency failures.
- Verify both first-load and reload behavior; confirm that frames, events, timers, and saved state are not duplicated.
- Record the client version, addon interface version, reproduction steps, and observed result for failures.
- If no client or project test command is available, state that validation is limited to static inspection and diagnostics.