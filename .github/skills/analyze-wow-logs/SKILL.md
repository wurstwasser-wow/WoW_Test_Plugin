---
name: analyze-wow-logs
description: "Read World of Warcraft log files, filter messages for this addon, save the relevant output, analyze errors, and suggest fixes. Use when diagnosing WoW addon Lua errors, load failures, taint, slash commands, or runtime behavior."
argument-hint: "Optional log directory or plugin name"
---

# Analyze WoW Logs

Collect and analyze World of Warcraft text logs for `WoW_Test_Plugin` or another specified addon.

## Procedure

1. Ask the user to close WoW before reading logs if the files may still be written.
2. Use the Retail log directory `C:\Program Files (x86)\World of Warcraft\_retail_\Logs` by default, or accept an explicit `-LogPath`.
3. Use `WoW_Test_Plugin` as the default plugin filter, or accept an explicit `-PluginName`.
4. Run [analyze-wow-logs.ps1](./scripts/analyze-wow-logs.ps1) with an output directory outside the game installation.
5. Review `filtered.log` for all matching plugin lines, `analysis.md` for grouped errors and suggested fixes, and `summary.json` for machine-readable results.
6. Correlate the report with the relevant Lua or TOC source before proposing a code change.
7. Report the exact input directory, filter, output directory, number of matching lines, and whether an in-game reproduction is still needed.

## Log Sources and Limitations

- WoW only provides useful addon messages when the relevant logging or error reporting was enabled in the client.
- Inspect `.txt` and `.log` files recursively; do not assume every client build uses the same filename.
- Treat suggestions as hypotheses. Confirm API names, line numbers, load order, combat lockdown, and dependency state before editing code.
- Never modify or delete the original WoW logs.
- Do not include account identifiers, chat content, or other unrelated personal data in a report unless needed for diagnosis.
- If no logs or matching lines are found, report that clearly and suggest enabling Lua error display or reproducing the issue with logging enabled.