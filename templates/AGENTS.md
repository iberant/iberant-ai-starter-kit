# Project Agent Instructions

> This file is the **single source of truth** for AI coding agents (Claude Code, Codex,
> Cursor, Copilot, …). `CLAUDE.md` is a symlink to this file.
> Keep it **under 200 lines**. Move detail into the sub-files referenced under "Architecture".
> Code style is enforced by the linter/formatter, **not** by this file.

## Core Invariants

These rules take precedence over all other guidance in this file.

1. **Don't assume. Don't hide confusion. Surface tradeoffs.** If something is ambiguous or has meaningful alternatives, say so before proceeding. Never silently pick one path.
2. **Minimum code that solves the problem. Nothing speculative.** Write only what the task requires. No extra abstractions, no future-proofing, no "while I'm here" cleanup.
3. **Touch only what you must. Clean up only your own mess.** Scope changes tightly to the problem. Don't refactor surrounding code unless you broke it.
4. **Define success criteria. Loop until verified.** Before starting, state what "done" looks like. After changes, verify that criterion is met — build, test, or observable behavior — before reporting complete.

## Language

- Write all **code, comments, identifiers, log messages, and commit messages in English**.
- Team-facing docs/guides may be written in another language, but anything in the codebase stays English.

## Standard Commands

The agent uses these to verify its work. Keep them as single, obvious commands.

```bash
# Frontend (Vite/React) with pnpm. Backend (ASP.NET Core) alternative in comments.
pnpm run dev     # start dev server          (backend: dotnet run)
pnpm test        # run the full test suite    (backend: dotnet test)
pnpm run lint    # linter + formatter check   (backend: dotnet format)
pnpm run build   # production build           (backend: dotnet build)
```

- Use **pnpm** for the frontend (not npm/yarn). Formatting is enforced by Prettier via `pnpm run lint`.

## Worktree Discipline

- Always verify `pwd` before editing; this repo may use git worktrees and edits must land in the active worktree, not the main repo path.
- If a worktree directory appears missing or stale, stop and ask before retrying exploration.

## Traceability

- Add useful trace information for new implementation paths, especially at process boundaries, external tool/API calls, persistence reads/writes, approval/permission decisions, and error/fallback branches.
- Trace logs should include stable correlation identifiers where available (request id, sub-chat id, session/thread id, workspace/project id) plus the outcome and compact reason/error. Avoid logging secrets, tokens, full prompts, large payloads, or noisy per-frame/per-keystroke data.
- Prefer existing logging conventions and prefixes in the touched area. If no convention exists, use a concise component prefix that makes the source searchable.

## Change Scope

- Prefer the simplest fix that solves the reported problem; do not introduce new config fields, abstractions, or specificity hacks before reading the relevant library/theming docs.
- When a user says 'one-line fix', apply only that — do not refactor surrounding code.

## Postmortems

- Document every issue or bugfix under `docs/postmortems/`. Folders are dated and descriptively named (e.g., `2026-05-04-fix-<short-slug>/`) and contain a short markdown summary covering trigger, root cause, fix, and verification steps, plus any DB scripts or other artifacts the fix required. One folder per logical change.

## Architecture

Detailed context lives in sub-files so this file stays small. Read on demand:

- Architecture & key decisions: @docs/Architecture.md
- (add more as the project grows, e.g. @docs/Testing.md, @docs/Database.md)
