---
name: World of Warcraft Addon Packaging
description: "Use when creating or modifying World of Warcraft addon TOC metadata, file manifests, dependencies, load order, or packaging conventions."
applyTo: "**/*.toc"
---

# World of Warcraft Addon Packaging

- Keep the addon folder name, TOC filename, title, and any declared namespace or identifier consistent.
- Set the interface version to the project’s supported WoW client and update it deliberately when support changes.
- List every required source, XML, localization, and library file in load order; load dependencies before consumers.
- Declare required dependencies explicitly and distinguish optional dependencies from required ones.
- Keep metadata accurate, including saved variables and load conditions, and avoid relying on filesystem ordering.
- Validate packaging by installing the addon in a clean client location and checking the addon list and load errors.