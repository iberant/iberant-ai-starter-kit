# Walkthrough: una sesión completa de principio a fin

Este documento **simula** una sesión real con Claude Code para que veas, paso a paso, **qué esperar
en cada momento**: cuándo cambiar de modelo, cómo te hará preguntas antes de planificar, cómo
apruebas el plan y empieza la implementación, qué evidencia muestra al final, etc.

> ⚠️ **Es un ejemplo simplificado, no una sesión real.** La salida de Claude está abreviada e
> inventada para ilustrar el flujo; en una sesión de verdad será más larga y detallada. El objetivo
> es que reconozcas **la forma** de cada paso, no copiar literalmente.

**La tarea de ejemplo:** añadir un buscaminas (*minesweeper*) HTML5 de **una sola página** a un
proyecto web pequeño que ya existe. Es una feature deliberadamente simple.

Sigue el ciclo de la **Parte B** de la [guía](STARTUP.md):

```
worktree → explore → plan → implement → review → PR → human-review → merge
```

### Cómo leer este documento

| Marca | Significa |
| --- | --- |
| `$` en un bloque `bash`/`powershell` | Un comando que tecleas en **tu terminal** (shell). |
| 👤 **You** | Lo que **tú** escribes en el prompt de Claude Code. |
| 🤖 **Claude** | La respuesta (simulada y abreviada) de Claude. |

---

## Paso 1 — Crea el worktree

Cada tarea vive en su propio worktree aislado. En tu terminal normal:

```bash
$ git worktree add ../web-feature-minesweeper -b feature/minesweeper
Preparing worktree (new branch 'feature/minesweeper')
HEAD is now at 9a3f1c2 chore: project setup

$ cd ../web-feature-minesweeper
```

Ahora abre Claude Code **dentro** de ese directorio:

```bash
$ claude
```

> 💡 Verás el prompt de Claude. Todo lo que sigue marcado con 👤 se escribe **ahí**, no en la shell.

> ⚡ **Alternativa — saltarte las confirmaciones de permisos.** Por defecto Claude te pide permiso
> antes de cada acción con efectos (editar ficheros, ejecutar comandos). Para una sesión sin
> interrupciones puedes lanzarlo así:
> ```bash
> $ claude --dangerously-skip-permissions
> ```
> Como dice el nombre, es **peligroso**: Claude editará y ejecutará **sin preguntar**. Úsalo solo
> cuando confíes en la tarea y estés en un entorno aislado —y aquí lo estás: este worktree es una
> copia con su propia rama, así que cualquier desastre queda contenido y es reversible (`git`). Si
> no, déjalo desactivado y aprovecha la `allowlist` de `settings.json` para reducir las
> interrupciones sin renunciar al control (ver [Buenas prácticas](STARTUP.md#buenas-prácticas)).

---

## Paso 2 — Empieza limpio y activa `opusplan`

Lo primero de cada tarea: contexto limpio y el modo de modelo correcto.

> 👤 **You**
> ```
> /clear
> ```

> 🤖 **Claude**
> ```
> Context cleared. Starting fresh.
> ```

> 👤 **You**
> ```
> /model opusplan
> ```

> 🤖 **Claude**
> ```
> Model set to opusplan:
>   • Plan mode  → Opus   (deep reasoning for design)
>   • Execution  → Sonnet (fast & cheap for implementation)
> ```

*¿Por qué ahora? Planificarás con el modelo potente (Opus) y, al implementar, Claude cambia solo a
Sonnet —barato. Ver [glosario](STARTUP.md#qué-es-glosario-mínimo).*

---

## Paso 2 (cont.) — Explorar (en plan mode, sin editar)

Antes de planificar, deja que Claude entienda el proyecto. En **plan mode** solo lee, no edita.

> 👤 **You**
> ```
> Read the project and tell me how the existing pages are structured and where a new
> single-page game would fit. Don't write any code yet.
> ```

> 🤖 **Claude** *(running on Opus, plan mode — read-only)*
> ```
> I explored the repo. Here's what I found:
>
>   • Static site, no framework. Pages live in /public/*.html and load /src/<page>.js.
>   • Build: `pnpm run build` (esbuild). Dev server: `pnpm run dev`.
>   • Tests: `pnpm test` (Vitest) — game logic is unit-tested under /src/__tests__.
>   • Styling: one shared /public/styles.css; no CSS framework.
>
> A new game fits as: public/minesweeper.html + src/minesweeper.js, with pure logic
> (board, mine placement, reveal) split into src/minesweeper-core.js so it can be unit-tested.
>
> No edits made (plan mode).
> ```

---

## Paso 2 (cont.) — Pide el plan

> 👤 **You**
> ```
> /plan build a single-page HTML5 minesweeper
> ```

Aquí ocurre algo importante: **antes de escribir el plan, Claude te hace preguntas** para no asumir
(Core Invariant #1). En Claude Code esto aparece como un menú interactivo:

> 🤖 **Claude** *(asks before planning)*
> ```
> Before I plan, a few decisions:
>
> 1) Board size / difficulty
>    ▸ Fixed 9×9, 10 mines (classic beginner)      ← recommended, simplest
>      Three presets (beginner/intermediate/expert)
>      User-configurable width/height/mines
>
> 2) Win/lose feedback
>    ▸ In-page banner + restart button             ← recommended
>      Browser alert()
>
> 3) Persistence
>    ▸ None — fresh game on reload                  ← recommended for v1
>      Save best time to localStorage
> ```

> 👤 **You** *(eliges con las flechas; aquí tomas las recomendadas)*
> ```
> 1 → Fixed 9×9, 10 mines
> 2 → In-page banner + restart
> 3 → None
> ```

> 🤖 **Claude** *(writes the plan, still on Opus — no code yet)*
> ```
> ## Plan: single-page HTML5 minesweeper
>
> ### Context
> Add a self-contained minesweeper at /minesweeper. Pure game logic separated from DOM so
> it can be unit-tested, matching the repo's existing logic/UI split.
>
> ### Files to create
>   • public/minesweeper.html  — markup + link to styles.css and minesweeper.js
>   • src/minesweeper-core.js   — pure logic: createBoard, placeMines, reveal, checkWin
>   • src/minesweeper.js        — DOM rendering + click handling, imports the core
>   • src/__tests__/minesweeper-core.test.js — unit tests for the core
>
> ### Approach
>   1. Core: 9×9 grid, 10 mines placed randomly (seedable for tests), flood-fill reveal of
>      empty cells, win when all non-mine cells revealed.
>   2. UI: render grid as buttons, left-click reveal, right-click flag, banner on win/lose,
>      restart button re-inits the board.
>   3. No build/config changes needed (esbuild picks up the new entry).
>
> ### Success criteria
>   • `pnpm test` green (core logic), `pnpm run build` succeeds.
>   • Manual: open /minesweeper, reveal cells, flag, hit a mine → lose banner; clear board → win.
>
> Press Ctrl+G to open this plan in your editor.
> ```

---

## Paso 3 — Cuestiona el plan

No aceptes a la primera: somételo a crítica de *senior engineer*.

> 👤 **You**
> ```
> /critique-plan
> ```

> 🤖 **Claude**
> ```
> Critique (senior-engineer lens):
>
> • Hidden assumption: "place 10 mines randomly" can collide and place fewer than 10.
>   → Fix: place mines via shuffle of cell indices, take first 10. Plan updated.
> • Edge case: first click could be a mine (bad UX). Worth deciding now.
>   → Recommend: guarantee first click is safe (place mines AFTER first click). Low cost.
> • Testability: randomness makes tests flaky.
>   → Fix: inject a seedable RNG into placeMines so tests are deterministic. Plan updated.
>
> Revised plan reflects these. Two alternatives considered (CSS-grid vs <table>): going with
> CSS grid — simpler, no table semantics needed.
> ```

Lees el plan revisado a fondo. Estás de acuerdo. **Este es el momento más barato para corregir.**

---

## Paso 4 — Aprueba e implementa

Para arrancar la implementación, **sales del plan mode** (en Claude Code se aprueba el plan; suele
ser una tecla, p. ej. aceptar el plan propuesto). Al salir, Claude pasa **automáticamente a Sonnet**.

> 👤 **You** *(apruebas el plan y pides ejecutar)*
> ```
> Looks good. Implement the plan. Verify against the success criteria, run the test suite,
> and fix any failures.
> ```

> 🤖 **Claude** *(now running on Sonnet — fast & cheap)*
> ```
> Implementing.
>
>   + src/minesweeper-core.js        (createBoard, placeMines(seed), reveal, checkWin)
>   + src/minesweeper.js             (render grid, click/flag handlers, win/lose banner)
>   + public/minesweeper.html        (container + restart button)
>   + src/__tests__/minesweeper-core.test.js   (6 tests)
>
> [hook] pnpm run lint --fix  → ok
>
> Running the test suite…
>   ✓ places exactly 10 mines (deterministic seed)
>   ✓ first click is never a mine
>   ✓ reveal floods empty neighbors
>   ✓ revealing a mine ends the game
>   ✓ clearing all safe cells wins
>   ✓ flag toggles and blocks reveal
>   Test Files  1 passed (1)   Tests  6 passed (6)
>
> Verified against success criteria: tests green. Next I'd build and you do a manual check.
> ```

*Fíjate: Claude **muestra evidencia** (la salida de los tests), no solo dice "hecho". El hook de
lint corrió solo tras editar, porque copiaste `settings.json` (ver
[Buenas prácticas](STARTUP.md#buenas-prácticas)).*

---

## Paso 5 — Pruebas

Corre el *safety net* completo y haz una prueba **manual** del comportamiento.

> 👤 **You**
> ```
> Run lint, build and tests together and show the output.
> ```

> 🤖 **Claude**
> ```
> $ pnpm run lint && pnpm run build && pnpm test
>   lint:  0 problems
>   build: public/minesweeper.html + bundle written to dist/ (0 errors)
>   test:  6 passed (6)
> All green.
> ```

Y tú, a mano, en el navegador:

```bash
$ pnpm run dev          # abre http://localhost:5173/minesweeper.html
```

Revelas casillas, pones banderas, pisas una mina → banner de derrota; reinicias y despejas → banner
de victoria. Funciona. **Si no puedes verificarlo, no lo entregues.**

---

## Paso 6 — Code review con IA + PR

Revisión en **contexto fresco** (un subagente sin sesgo). **No hagas `/clear` aquí.**

> 👤 **You**
> ```
> /code-review
> ```

> 🤖 **Claude** *(fresh subagent reviews the diff)*
> ```
> Reviewed the diff (4 files). Findings:
>
> • [correctness] src/minesweeper.js:42 — right-click opens the browser context menu;
>   call e.preventDefault() in the flag handler. ← worth fixing
> • [minor] core looks correct; reveal flood-fill is iterative (no stack overflow). 👍
>
> No requirement gaps. No out-of-scope changes.
> ```

> 👤 **You**
> ```
> Fix the preventDefault finding only.
> ```

> 🤖 **Claude**
> ```
>   ~ src/minesweeper.js  (added e.preventDefault() in contextmenu handler)
>   [hook] lint → ok
>   ✓ tests still 6 passed
> ```

*Solo perseguiste lo que afecta a **correctitud**; lo demás sería sobre-ingeniería.*

Ahora crea el commit y el PR. Puedes hacerlo tú a mano:

```bash
$ git add -A && git commit -m "feat(games): add single-page HTML5 minesweeper"
$ gh pr create --fill
https://github.com/your-org/web/pull/231
```

**O pídele a Claude que lo haga por ti** (sigue en la misma sesión, con todo el contexto del cambio):

> 👤 **You**
> ```
> Commit the changes with a conventional-commits message, then open a PR with gh.
> Use the plan as the PR body (what & why), and reference the issue if there is one.
> ```

> 🤖 **Claude**
> ```
> $ git add -A
> $ git commit -m "feat(games): add single-page HTML5 minesweeper"
>   [feature/minesweeper 4b1c9e0] feat(games): add single-page HTML5 minesweeper
> $ gh pr create --fill
>   https://github.com/your-org/web/pull/231
>
> PR opened. Title and body follow conventional commits and summarize the what & why.
> ```

---

## Paso 7 — Revisión humana

El PR se abre con la plantilla de checklist (tests, docs, sin secretos). Un compañero lo revisa en
GitHub. **La responsabilidad del merge sigue siendo humana** — la IA solo aceleró el camino.

---

## Paso 8 — Merge con squash

**Squash and merge**, con título *conventional commits* y cuerpo que explica el qué y el porqué:

```
feat(games): add single-page HTML5 minesweeper

- 9×9 / 10 mines, first click always safe, seedable RNG for tests
- pure core logic unit-tested; CSS-grid UI with flag + restart
```

Como fue una **feature** (no un bug), documentas brevemente bajo `docs/` y limpias el worktree:

```bash
$ cd ../web
$ git worktree remove ../web-feature-minesweeper
```

> Si en vez de una feature hubieras arreglado un **bug**, el cierre incluiría un `/postmortem`
> (ver [Paso 4b](STARTUP.md#paso-4b--variante-corregir-un-bug)).

---

## Lo que acabas de ver

| Momento | Qué pasó |
| --- | --- |
| `/clear` + `/model opusplan` | Empezar limpio; Opus para pensar, Sonnet para ejecutar. |
| Explore (plan mode) | Claude **lee** sin editar y resume el proyecto. |
| `/plan` | Claude **pregunta antes de asumir**, luego escribe el plan. |
| `/critique-plan` | Se cazan supuestos y casos límite **antes** de codificar. |
| Aprobar → implementar | Sales de plan mode; ejecución en Sonnet; **muestra evidencia**. |
| `/code-review` | Subagente fresco; persigues solo correctitud. |
| PR → review humano → squash merge | La IA acelera; el merge lo firma un humano. |

Cuando lo tengas claro, vuelve a la [guía completa (STARTUP.md)](STARTUP.md) para los detalles de
cada paso.
