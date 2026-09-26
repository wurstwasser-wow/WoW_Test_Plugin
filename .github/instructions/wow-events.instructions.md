---
name: World of Warcraft Event Handling
description: "Use when creating or modifying World of Warcraft event registration, callbacks, slash commands, timers, or lifecycle handling in Lua."
applyTo: "**/*.lua"
---

# World of Warcraft Event Handling

- Register only the events a feature needs and unregister them when the feature or frame no longer needs updates.
- Keep event handlers small; validate event arguments and delegate feature logic to named local functions.
- Make initialization and repeated event delivery idempotent so reloads and duplicate notifications do not duplicate UI or state.
- Avoid expensive work on high-frequency events; throttle or defer updates when the feature does not require every notification.
- Treat combat and addon-load lifecycle events as state transitions, and handle unavailable APIs or data without breaking the addon.
- Test relevant login, reload, combat, zone, and logout transitions in the WoW client.