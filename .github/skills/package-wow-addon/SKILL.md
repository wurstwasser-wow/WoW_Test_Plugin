---
name: package-wow-addon
description: "Create a distributable World of Warcraft addon installation bundle, such as a CurseForge ZIP. Use when asked to package, archive, release, or prepare this addon for upload."
argument-hint: "Optional output directory or package version"
---

# Package WoW Addon

Create a CurseForge-compatible ZIP containing the addon folder and only the files declared by its TOC manifest.

## Procedure

1. Read the addon TOC and confirm the declared interface and version.
2. Use the TOC basename as the addon folder name and the TOC `## Version` value in the output filename.
3. Run [package-wow-addon.ps1](./scripts/package-wow-addon.ps1), optionally passing `-OutputDirectory` or `-Version`.
4. Confirm the ZIP has exactly one top-level addon folder, contains the TOC and every manifest file, and excludes `.git`, `.github`, `.vscode`, README files, and other workspace metadata.
5. Report the exact bundle path and the command used to create it.

## Package Rules

- Keep the TOC at the root of the addon folder inside the ZIP.
- Preserve subdirectories listed in the TOC, including localization, libraries, and XML paths.
- Do not include secrets, editor settings, Git history, development instructions, or unrelated files.
- Do not modify source files while packaging.
- If a manifest file is missing, stop and report it instead of creating a partial archive.

## CurseForge Check

The resulting archive should be uploaded as a ZIP whose contents begin with `<addon-folder>\<addon>.toc`, not with an extra repository or version directory.