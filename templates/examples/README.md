# Stack examples

Concrete configuration and command examples for the two stacks we use: a **Vite + React**
frontend and an **ASP.NET Core** backend. Copy what applies to your project and adapt it.

## Vite + React (frontend)

Use **pnpm** as the package manager (not npm/yarn). The `packageManager` field in
[`vite-react/package.json`](vite-react/package.json) pins it so Corepack picks it up.

Standard commands (put these in `AGENTS.md` → `Standard Commands`):

```bash
pnpm install     # install dependencies
pnpm run dev     # start dev server (http://localhost:5173)
pnpm test        # vitest
pnpm run lint    # eslint + prettier --check
pnpm run format  # prettier --write (autofix formatting)
pnpm run build   # production build (tsc + vite build)
```

Formatting:

- **Prettier** is the formatter. The config lives in the `"prettier"` block of
  [`vite-react/package.json`](vite-react/package.json) (or a standalone `.prettierrc.json`):
  `printWidth: 120`, `singleQuote: true`, `semi: true`, `trailingComma: "none"`, `tabWidth: 2`,
  `bracketSameLine: true`, `bracketSpacing: true`, `useTabs: false`.
- Style is enforced by Prettier/ESLint, **not** by `AGENTS.md`. `pnpm run lint` fails the build if
  formatting drifts, so the agent can verify it.

Configuration & secrets:

- Env vars live in `.env` / `.env.local` (see [`vite-react/.env.example`](vite-react/.env.example)).
- Only `VITE_`-prefixed vars reach the client, and they are **bundled into the browser** —
  treat them as public. **Never** put API keys or secrets in a Vite env var; keep those on the
  ASP.NET Core side.

## ASP.NET Core (backend)

Standard commands:

```bash
dotnet run                 # start the API (https://localhost:5001)
dotnet test                # run the test suite
dotnet format --verify-no-changes   # format/lint check
dotnet build               # build / compile
```

Configuration & secrets:

- [`aspnet-core/appsettings.json`](aspnet-core/appsettings.json) — committed base config, **no real
  secrets** (placeholders only).
- [`aspnet-core/appsettings.Development.json`](aspnet-core/appsettings.Development.json) — local dev
  overrides (a localhost connection string is fine here).
- Real secrets do **not** go in these files. For local dev use User Secrets; in production use
  environment variables (which override the JSON via the `:` / `__` convention):

  ```bash
  # Local development — stored outside the repo, never committed (same on macOS & Windows):
  dotnet user-secrets init
  dotnet user-secrets set "ConnectionStrings:Default" "Host=...;Password=..."
  dotnet user-secrets set "Api:ApiKey" "real-key"
  ```

  ```bash
  # Production — environment variables, double underscore = nested key.
  # macOS / Linux:
  export ConnectionStrings__Default="Host=...;Password=..."
  export Api__ApiKey="real-key"
  ```

  ```powershell
  # Windows (PowerShell):
  $env:ConnectionStrings__Default = "Host=...;Password=..."
  $env:Api__ApiKey = "real-key"
  ```

> Wiring them together: the React app calls the API at `VITE_API_BASE_URL`, and the API allows the
> frontend origin via the `Cors:AllowedOrigins` setting in `appsettings.json`.
