# Architecture

> Keep this focused (aim for ~2 pages). This is the file agents read to understand the
> system without you re-explaining it every session. Update it when a structural decision changes.

## Overview

One paragraph: what this system does and who uses it.

## Tech Stack

- Frontend: React + Vite (TypeScript)
- Backend: ASP.NET Core (.NET 8, C#)
- Datastore: PostgreSQL
- Infra: <e.g. Docker, Azure>

See [examples/](../examples/README.md) for the standard commands and config/secret conventions
of each stack.

## Module Map

| Path | Responsibility |
| --- | --- |
| `src/api/` | HTTP layer / controllers |
| `src/core/` | Domain logic |
| `src/db/` | Persistence, migrations |

## Key Decisions (ADR-style)

- **<Decision>** — <why>. Tradeoff accepted: <…>.

## Gotchas / "Why is this weird?" (important for brownfield)

Hidden context an agent cannot infer from the code alone. Examples:

- The `auth` flow refreshes tokens twice on purpose — the upstream IdP is sensitive to clock skew.
- `legacy_sync.py` must run before `import_job` or rows are dropped silently.
- Service X is timing-sensitive; do not parallelize calls to it.
