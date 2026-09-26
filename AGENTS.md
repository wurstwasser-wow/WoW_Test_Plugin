# Agent Instructions

## Git and GitHub commands

- Whenever a task involves Git or GitHub, always provide every command needed to perform the operation locally.
- Show commands in complete, copyable code blocks and in the exact order they should be run.
- Include relevant inspection commands such as `git status`, `git branch -vv`, `git remote -v`, or `git log` when they are part of the workflow.
- Include the exact branch names, remote name, commit message, and push flags used; do not replace them with unexplained placeholders when the repository values are known.
- When a command rewrites history or force-pushes, state that explicitly and show the exact `git push --force-with-lease` command.
- After GitHub operations, report the verification commands and their expected purpose.

## Project status

- This repository is a World of Warcraft addon targeting client interface `12.1.0`.
- Keep `.vscode/` ignored and out of commits; it is local editor configuration.