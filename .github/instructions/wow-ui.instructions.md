---
name: World of Warcraft UI and Frames
description: "Use when creating or modifying World of Warcraft UI, frame, widget, template, or XML layout code."
applyTo: "**/*.{lua,xml}"
---

# World of Warcraft UI and Frames

- Prefer the project’s existing frame and widget patterns once they are established.
- Keep frame names, anchors, strata, sizing, and parent-child relationships explicit and stable.
- Use Blizzard templates and secure frame mechanisms when the UI interacts with protected actions; do not bypass combat restrictions.
- Separate UI construction from event and business logic so each can be reasoned about and tested independently.
- Account for reloads, repeated initialization, combat lockdown, and missing optional data when updating visible state.
- Validate layout and interaction in the WoW client at the supported UI scale and relevant combat states.