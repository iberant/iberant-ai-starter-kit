# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a **starter kit**, not an application. It ships two things:

1. **A step-by-step guide** (in Spanish) for making any project — greenfield or brownfield —
   ready to work with AI coding assistants (Claude Code, Codex) productively and safely.
2. **Copy-paste templates** under `templates/` that users drop into their own project's root
   (agent instructions, setup scripts, slash commands, hooks, PR template, postmortems).

There is **no build, test, or lint here** — no `package.json`, no source code, no CI. The
`pnpm`/`dotnet` commands you see in the docs and in `templates/` are instructions for the
*downstream* project that adopts the kit; they do not run against this repo. Don't try to
"run" or "build" this repo. Verification here means: prose is correct, code blocks are valid,
and cross-references resolve.

## Layout

- `README.md` — entry point and the recurring per-task checklist.
- `STARTUP.md` — the full guide. **This is the primary document.** Part A = one-time repo setup;
  Part B = the recurring per-feature/bug cycle (`worktree → explore → plan → implement → review → PR → human-review → merge`).
- `WALKTHROUGH.md` — a simulated end-to-end session (building a minesweeper) illustrating the Part B flow.
- `templates/` — the artifacts users copy. Mirrors a target project's root: `AGENTS.md`,
  `.claude/` (settings, commands, skills), `scripts/`, `docs/`, `examples/`, `.github/`.

## Core conventions (these govern edits here)

- **Language split is a hard rule.** Team-facing docs/guides (`README.md`, `STARTUP.md`,
  `WALKTHROUGH.md`) are written in **Spanish**. Everything inside `templates/` and any code,
  commands, filenames, identifiers, and commit messages are **English**. Keep this split when editing.
- **`AGENTS.md` is the source of truth; `CLAUDE.md` is a symlink to it.** In `templates/`,
  `templates/CLAUDE.md` reads as identical to `templates/AGENTS.md` because it is that symlink —
  edit `templates/AGENTS.md`, never the symlink. (This repo's own root `CLAUDE.md` — this file — is a
  normal file, not a symlink.)
- **`AGENTS.md` must stay under 200 lines.** The kit's own thesis is that LLMs reliably follow only
  ~150–200 instructions; occasional knowledge belongs in skills or `docs/` sub-files referenced with
  `@docs/...`, not inline. Respect this when editing `templates/AGENTS.md`.
- **Code style lives in the linter, not in agent instructions.** Don't add style rules to `AGENTS.md`.

## Editing the docs

The three top-level docs and `templates/` are **tightly cross-linked** — `README.md` and
`WALKTHROUGH.md` deep-link into `STARTUP.md` section anchors, and all three reference specific files
under `templates/`. When you change a heading, rename/move a template file, or alter a step:

- Update every reference to it (anchors are GitHub-slugified, accents stripped, spaces → `-`).
- Keep the canonical task flow string consistent everywhere it appears:
  `worktree → explore → plan → implement → review → PR → human-review → merge`.
- The two supported stacks are **Vite + React (pnpm)** for frontend and **ASP.NET Core (.NET)** for
  backend. When you add a stack-specific command, show both (bash for macOS/Linux, PowerShell for
  Windows) — the kit explicitly targets macOS **and** Windows.

## Two audiences — don't confuse them

When editing, be clear about who a file speaks to:

- **The human adopting the kit** — `README.md`, `STARTUP.md`, `WALKTHROUGH.md`. Explanatory, Spanish.
- **The AI agent in the adopter's project** — files under `templates/` (`AGENTS.md`, slash commands,
  `SKILL.md`). Imperative, English, copied verbatim into someone else's repo. Changes here change the
  product the kit hands out, so match the existing terse, instruction-style voice.
