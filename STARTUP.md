# Guía: convertir un proyecto en uno compatible con IA

Esta guía describe, paso a paso, cómo dejar un repositorio listo para trabajar con asistentes
de IA (Claude Code y Codex) de forma productiva y segura. Sirve tanto para un proyecto nuevo
(*greenfield*) como para uno ya existente (*brownfield*).

La guía se divide en dos partes:

- **Parte A — Configuración inicial:** se hace **una sola vez** por repositorio.
- **Parte B — Ciclo por cada feature/bug/issue:** se **repite** en cada cambio que hagas.

> **Convención de esta guía:** la explicación está en español, pero **todos los comandos, el
> código y el contenido de los ficheros (`AGENTS.md`/`CLAUDE.md`, scripts, settings) van en
> inglés**. Las plantillas listas para copiar están en [`templates/`](templates/).
>
> El equipo trabaja en **macOS y Windows**. Donde un comando difiere entre sistemas se muestran
> ambas variantes (**macOS/Linux** en `bash` y **Windows** en `PowerShell`); cuando es idéntico
> (`git`, `gh`, `npm`, `dotnet`, slash commands) se muestra una sola vez.

## Índice

- [¿Qué significa "AI-ready"?](#qué-significa-ai-ready)
- [¿Qué es…? (glosario mínimo)](#qué-es-glosario-mínimo)
- [Greenfield vs Brownfield](#greenfield-vs-brownfield)
- **Parte A — Configuración inicial (una sola vez)**
  - [Requisitos e instalación](#requisitos-e-instalación)
  - [Windows: developer mode + symlinks](#windows-developer-mode--symlinks)
  - [Establecer el "safety net"](#establecer-el-safety-net)
  - [Inicializar AGENTS.md / CLAUDE.md](#inicializar-agentsmd--claudemd)
  - [Las reglas core (Karpathy)](#las-reglas-core-karpathy)
  - [Comandos y skills: cómo invocarlos](#comandos-y-skills-cómo-invocarlos)
- **Parte B — Ciclo por cada feature / bug / issue (recurrente)**
  - [Paso 1 — Crear un worktree](#paso-1--crear-un-worktree)
  - [Paso 2 — Explorar y planificar](#paso-2--explorar-y-planificar)
  - [Paso 3 — Cuestionar el plan](#paso-3--cuestionar-el-plan)
  - [Paso 4 — Implementar](#paso-4--implementar)
  - [Paso 4b — Variante: corregir un bug](#paso-4b--variante-corregir-un-bug)
  - [Paso 5 — Pruebas](#paso-5--pruebas)
  - [Paso 6 — Code review con IA + PR](#paso-6--code-review-con-ia--pr)
  - [Paso 7 — Revisión humana](#paso-7--revisión-humana)
  - [Paso 8 — Merge con squash](#paso-8--merge-con-squash)
- [Buenas prácticas](#buenas-prácticas)
- [Fuentes](#fuentes)

---

## ¿Qué significa "AI-ready"?

Un repositorio AI-ready le da al asistente todo lo que necesita para escribir código correcto y
alineado con tus convenciones **sin que tengas que repetírselo cada sesión**. En la práctica son
tres cosas:

1. **Contexto persistente** — un `AGENTS.md` que explica el qué, el porqué y el cómo del proyecto.
2. **Un "safety net" verificable** — comandos estándar, linter, tests y CI que permiten a la IA
   comprobar su propio trabajo (cerrar el bucle sin que tú seas el verificador).
3. **Un flujo de trabajo disciplinado** — planificar → cuestionar → implementar → revisar.

Las dos primeras se montan **una vez** (Parte A). La tercera se **repite** en cada cambio (Parte B).

## ¿Qué es…? (glosario mínimo)

Si es tu primera vez con asistentes de IA, estos son los términos que usa la guía. No necesitas
memorizarlos: vuelve aquí cuando aparezca alguno.

| Término | Qué es |
| --- | --- |
| **Asistente / agente de IA** | Un programa (Claude Code, Codex) que vive en tu terminal, lee tu código y puede editarlo, ejecutar comandos y abrir PRs siguiendo tus instrucciones. |
| **Sesión** | Una conversación abierta con el asistente. Empieza al lanzar `claude`/`codex` y termina al cerrarlo. |
| **Contexto** | Todo lo que el asistente "tiene en mente" en la sesión (tu código, mensajes, ficheros leídos). Es **limitado**: cuando se llena, el asistente empieza a olvidar. Por eso conviene limpiarlo entre tareas (`/clear`). |
| **Token** | La unidad en que se mide (y se cobra) el texto que entra y sale del modelo. Más contexto = más tokens = más coste y más lento. |
| **Modelo** | El "cerebro" que usa el asistente. **Opus** = el más potente y caro (para razonar/planificar); **Sonnet** = rápido y barato (para ejecutar); **Haiku** = el más ligero. Se eligen con `/model`. |
| **Plan mode** | Un modo en el que el asistente **solo lee y propone un plan, sin editar código**. Sirve para pensar antes de tocar nada. |
| **Subagente** | Un asistente secundario que el principal lanza para una sub-tarea (p. ej. revisar un diff) con su **propio contexto limpio**, sin ensuciar tu sesión. |
| **Slash command** | Una orden que empieza por `/` (p. ej. `/plan`, `/clear`). Escribe `/` en el prompt y aparece el menú. |
| **Command vs Skill** | Un **command** lo lanzas tú a mano. Una **skill** es conocimiento que la IA puede **cargar sola** cuando detecta que aplica (y también puedes invocarla a mano). |
| **Hook** | Una acción automática y determinista que el asistente ejecuta en cierto momento (p. ej. correr el linter tras cada edición). No depende de que la IA "se acuerde". |
| **MCP** | Un conector que da al asistente acceso a herramientas externas (Jira, Figma, la base de datos, el navegador). |
| **Worktree** | Una copia de trabajo aislada del repo, con su propia rama, para que varias tareas no choquen entre sí. |

## Greenfield vs Brownfield

| | Greenfield (proyecto nuevo) | Brownfield (proyecto existente) |
| --- | --- | --- |
| Qué domina | El objetivo limpio | La **historia**: integraciones, excepciones, *workarounds* |
| Estrategia | Empieza con estructura y deja crecer la autonomía de la IA | Migración **incremental y reversible**; supervisión alta al principio |
| `AGENTS.md` | Conviene escribirlo a mano desde el inicio | Genera un borrador con `/init` y **corrige** lo que la IA infirió mal |
| Riesgo principal | Sobre-ingeniería | Romper comportamiento que "funciona por razones no obvias" |
| Clave | Convenciones claras | Documentar **por qué esto es raro** en `docs/Architecture.md` |

> En brownfield, no reescribas el monolito para meter IA: introduce cambios por límites bien
> definidos (adaptadores) y en fases pequeñas que puedas revertir.

---

# Parte A — Configuración inicial (una sola vez)

Esto se hace **una vez** al preparar el repositorio. Cuando termines la Parte A, el proyecto ya es
AI-ready y todo el equipo trabaja con la Parte B en el día a día.

## Requisitos e instalación

Antes de nada, instala las herramientas. La guía da por hecho que ya las tienes a partir de
«Establecer el "safety net"», así que **empieza por aquí**.

**1. Qué necesitas y para qué sirve:**

| Herramienta | Para qué | ¿Obligatoria? |
| --- | --- | --- |
| **git** | Control de versiones (ramas, worktrees, commits). | Sí |
| **Node.js + pnpm** | Ejecutar el frontend (Vite/React) y sus comandos `pnpm …`. | Si tu stack es frontend |
| **.NET SDK (`dotnet`)** | Ejecutar el backend (ASP.NET Core) y sus comandos `dotnet …`. | Si tu stack es backend |
| **GitHub CLI (`gh`)** | Crear y gestionar PRs desde la terminal (`gh pr create`). | Si usas GitHub |
| **Azure CLI (`az`)** | Crear PRs en Azure DevOps (`az repos pr create`). | Si usas Azure DevOps |
| **Claude Code** | El asistente de IA de Anthropic en tu terminal. | Sí (o Codex) |
| **Codex** | El asistente de IA de OpenAI en tu terminal. | Alternativa a Claude Code |

**2. Instalación.** Los comandos cambian con el tiempo; ante la duda, sigue la doc oficial enlazada.

```bash
# macOS / Linux (Homebrew para git, node, gh; pnpm vía corepack)
brew install git node gh
corepack enable && corepack prepare pnpm@latest --activate
# .NET (solo backend): https://dotnet.microsoft.com/download

# AI assistants (npm trae Node del paso anterior):
npm install -g @anthropic-ai/claude-code     # Claude Code
npm install -g @openai/codex                  # Codex
```

```powershell
# Windows (PowerShell) con winget
winget install Git.Git OpenJS.NodeJS GitHub.cli
corepack enable; corepack prepare pnpm@latest --activate
# .NET (solo backend): winget install Microsoft.DotNet.SDK.8

# AI assistants:
npm install -g @anthropic-ai/claude-code
npm install -g @openai/codex
```

> Docs oficiales (por si los comandos cambian): **Claude Code** —
> <https://code.claude.com/docs> · **Codex** — <https://developers.openai.com/codex> ·
> **GitHub CLI** — <https://cli.github.com> · **Azure CLI** — <https://learn.microsoft.com/cli/azure>.

**3. Autenticación (inicia sesión una vez por máquina):**

```bash
# Claude Code: lánzalo y la primera vez te guía el login (o usa /login dentro de la sesión).
claude

# Codex: la primera vez pide iniciar sesión (cuenta de OpenAI o API key).
codex

# GitHub / Azure DevOps:
gh auth login        # GitHub
az login             # Azure DevOps
```

**4. Lanzar y verificar que funciona.** Abre la terminal **en la raíz del repo** y arranca el asistente:

```bash
cd /ruta/a/tu/proyecto
claude               # (o: codex)
```

Sabrás que funciona si: aparece un **prompt** donde escribir, y al teclear `/` se despliega un **menú
de slash commands** (`/init`, `/clear`, `/model`, …). A partir de aquí, todo lo que la guía pone en
bloques `# (run inside Claude Code)` se teclea **en ese prompt**, no en tu shell.

## Windows: developer mode + symlinks

Solo en **Windows**. (En macOS/Linux los symlinks funcionan de serie; salta a «Establecer el
"safety net"».)

Necesitamos symlinks porque `CLAUDE.md` será un enlace a `AGENTS.md`. Activa el *Developer Mode*
y dile a git que materialice symlinks:

```powershell
# Open the Developer settings UI:
start ms-settings:developers

# Let git create symlinks on checkout (run once, global):
git config --global core.symlinks true
```

O ejecuta el script incluido en una PowerShell **como administrador**:

```powershell
.\templates\scripts\setup-windows-dev.ps1
```

> Si clonaste el repo antes de activar esto, vuelve a clonarlo o ejecuta `git checkout -- .`
> para que los symlinks se recreen.

## Establecer el "safety net"

**Este paso es la base de todo.** La regla #4 ("define el criterio de éxito y repite hasta
verificar") no sirve de nada si la IA no tiene **un check que ejecutar**. Antes de pedirle nada
serio al asistente, asegúrate de tener (los comandos `pnpm`/`dotnet` de abajo requieren las
herramientas de [Requisitos e instalación](#requisitos-e-instalación)):

1. **Comandos estándar, únicos y obvios** para arrancar, testear, lintar y construir. Decláralos
   en `AGENTS.md` (sección `Standard Commands`):

   ```bash
   # Frontend (Vite/React) with pnpm. Backend (ASP.NET Core) alternative in comments.
   pnpm run dev     # start dev server          (backend: dotnet run)
   pnpm test        # full test suite            (backend: dotnet test)
   pnpm run lint    # linter + formatter check   (backend: dotnet format)
   pnpm run build   # production build           (backend: dotnet build)
   ```

2. **Linter + formatter automáticos.** El estilo lo imponen herramientas deterministas (y baratas),
   **no** instrucciones en `AGENTS.md`. Configura uno de cada y córrelos en CI.

3. **Una red de tests** que cubra los flujos críticos (apunta a ~70% en lo importante). Es lo que
   permite a la IA "loop until verified".

4. **CI que bloquee el merge** si falla lint/test/build.

5. **Higiene de secretos**: nada hardcodeado. Usa `.env` (gitignorado) y un `.env.example`
   versionado. Copia [`templates/.gitignore`](templates/.gitignore) y
   [`templates/.env.example`](templates/.env.example).

> **Ejemplos por stack** (Vite/React y ASP.NET Core): comandos estándar, `.env` con prefijo
> `VITE_` y `appsettings.json` + manejo de secretos con *User Secrets* / variables de entorno en
> [`templates/examples/`](templates/examples/README.md). Regla clave: las variables `VITE_` viajan
> al navegador, así que **los secretos viven solo en el backend** (ASP.NET Core).

> En brownfield sin tests, empieza por escribir un test que reproduzca el bug **antes** de
> arreglarlo: así creas red de seguridad mientras avanzas.

## Inicializar AGENTS.md / CLAUDE.md

`AGENTS.md` es el **estándar neutral** que leen Claude Code, Codex, Cursor, Copilot, etc.
`CLAUDE.md` será un **symlink** a él, para que haya una única fuente de verdad.

### Con Claude Code

```text
# 1. Generate a draft from your codebase (run inside Claude Code):
/init
```

Después, renombra a `AGENTS.md` y crea el symlink `CLAUDE.md → AGENTS.md`:

```bash
# macOS / Linux
mv CLAUDE.md AGENTS.md
ln -s AGENTS.md CLAUDE.md
```

```powershell
# Windows (PowerShell) — requires Developer Mode (see "Windows: developer mode + symlinks")
Rename-Item CLAUDE.md AGENTS.md
New-Item -ItemType SymbolicLink -Path CLAUDE.md -Target AGENTS.md
```

O usa el script incluido:

```bash
./templates/scripts/link-agents.sh        # macOS / Linux
```

```powershell
.\templates\scripts\link-agents.ps1       # Windows (PowerShell)
```

### Con Codex

Codex ya usa `AGENTS.md` de forma nativa: créalo (o reutiliza el del paso anterior). Crea igualmente
el symlink `CLAUDE.md → AGENTS.md` para que cualquier herramienta funcione.

> **Alternativa (avanzada):** en vez de un symlink puedes tener un `CLAUDE.md` propio que
> importe el común y añada cosas específicas de Claude, con la sintaxis `@import`:
> ```markdown
> @AGENTS.md
>
> # Claude-specific
> - Prefer running single tests for speed.
> ```

## Las reglas core (Karpathy)

Copia la plantilla [`templates/AGENTS.md`](templates/AGENTS.md). Su núcleo son cuatro invariantes
que tienen prioridad sobre todo lo demás:

```markdown
## Core Invariants

These rules take precedence over all other guidance in this file.

1. **Don't assume. Don't hide confusion. Surface tradeoffs.** If something is ambiguous or has meaningful alternatives, say so before proceeding. Never silently pick one path.
2. **Minimum code that solves the problem. Nothing speculative.** Write only what the task requires. No extra abstractions, no future-proofing, no "while I'm here" cleanup.
3. **Touch only what you must. Clean up only your own mess.** Scope changes tightly to the problem. Don't refactor surrounding code unless you broke it.
4. **Define success criteria. Loop until verified.** Before starting, state what "done" looks like. After changes, verify that criterion is met — build, test, or observable behavior — before reporting complete.
```

La plantilla añade además secciones de `Worktree Discipline`, `Traceability`, `Change Scope`,
`Postmortems` y `Standard Commands`. Recuerda:

- **Menos es más.** Los LLM siguen con fiabilidad ~150–200 instrucciones; un fichero inflado hace
  que ignoren la mitad. Mantén `AGENTS.md` **por debajo de 200 líneas**.
- El **estilo de código** va al linter, no aquí.
- El **conocimiento ocasional** (convenciones de API, esquema de BD) va a *skills* o sub-ficheros,
  no en el contexto de cada sesión. Ver [Buenas prácticas](#buenas-prácticas).

## Comandos y skills: cómo invocarlos

Si no has usado asistentes por terminal, esto es lo mínimo. Tanto **Claude Code** como **Codex** se
manejan con **slash commands**: escribes `/` y aparece un menú con las opciones disponibles.

Hay dos tipos:

- **Integrados** (vienen de serie): `/init`, `/plan`, `/model`, `/clear`, `/compact`,
  `/code-review`, `/security-review`, … Los usas tal cual.
- **Propios del proyecto**: ficheros markdown bajo `.claude/commands/` y `.claude/skills/` que se
  convierten en comandos reutilizables (los de este kit están en
  [`templates/.claude/`](templates/.claude/) — cópialos a `.claude/` de tu proyecto).

> **¿Dónde viven?** Lo que pones en `.claude/` **del repo** está disponible para todo el equipo y se
> versiona con git. Lo que pones en `~/.claude/` (tu home) es **global**, solo tuyo, para todos tus
> proyectos.

**En Claude Code:**

- Un comando propio es un `.md` en `.claude/commands/` (formato clásico) o
  `.claude/skills/<name>/SKILL.md` (recomendado). Lo lanzas escribiendo `/<nombre>` y, si admite
  argumentos, los pones detrás: `/plan add OAuth login`. Dentro del fichero, `$ARGUMENTS` (o `$1`,
  `$2`) recibe lo que escribiste.
- Diferencia clave: un **command** lo lanzas tú a mano; una **skill** además puede invocarla la IA
  **automáticamente** cuando detecta que aplica (por su `description`). Por eso el conocimiento
  ocasional va en skills. Ejemplo real de este kit:
  [`api-conventions`](templates/.claude/skills/api-conventions/SKILL.md) se **autocarga** cuando le
  pides tocar un endpoint HTTP (no tienes que invocarla), y no ocupa contexto el resto del tiempo.
- Frontmatter útil: `description`, `argument-hint`, `allowed-tools`,
  `disable-model-invocation: true` (para acciones con efectos secundarios que solo quieras lanzar a
  mano).

**En Codex:**

- También se usa `/` para los slash commands. Para tus propios prompts reutilizables, crea ficheros
  markdown en `~/.codex/prompts/*.md` e invócalos desde el menú como `/prompts:<nombre>`, pasando
  argumentos con placeholders como `$1`, `$ARGUMENTS` o `$FILE`.
- El contexto persistente del proyecto va en el `AGENTS.md` que ya creaste (ver «Inicializar
  AGENTS.md / CLAUDE.md»), igual en ambos.

---

# Parte B — Ciclo por cada feature / bug / issue (recurrente)

Estos pasos se **repiten en cada cambio**. El flujo de cada tarea es:

> **worktree → explore → plan → implement → review → PR → human-review** (→ merge)

Empieza cada tarea con contexto limpio (`/clear`) en su propio worktree.

## Paso 1 — Crear un worktree

Cada tarea (feature/bug/issue) vive en su **propio git worktree**: una copia de trabajo aislada con
su propia rama. Así puedes tener varias tareas/sesiones de IA en paralelo sin que las ediciones
colisionen, y el árbol principal queda limpio.

```bash
# Create an isolated worktree + branch for the task:
git worktree add ../app-feature-oauth -b feature/oauth
cd ../app-feature-oauth

# ... do the work (steps 2–8) inside this directory ...

# After it is merged, remove the worktree:
git worktree remove ../app-feature-oauth
```

> Abre Claude Code / Codex **dentro** del worktree. Verifica siempre `pwd` antes de editar: las
> ediciones deben caer en el worktree activo, no en el repo principal (ver `Worktree Discipline`
> en [`templates/AGENTS.md`](templates/AGENTS.md)).

## Paso 2 — Explorar y planificar

Lo **primero** de cada tarea: activa el modo `opusplan`. Con él, el **plan mode usa Opus**
(razonamiento profundo para arquitectura) y la **implementación cambia automáticamente a Sonnet**
(rápido y barato). Así solo gastas tokens de Opus donde más valen —la planificación— y la ejecución
sale económica. (¿Qué son *modelo*, *Opus*, *Sonnet*, *token*, *plan mode*? Ver el
[glosario](#qué-es-glosario-mínimo).)

```text
/model opusplan
```

Luego, no dejes que la IA salte directa a codificar (resuelve el problema equivocado). El flujo
correcto es **Explorar → Planificar → Implementar → Commit**:

```text
# 1. Explore (plan mode → runs on Opus): read code, don't edit.
read /src/auth and explain how sessions and token refresh work.

# 2. Plan (still on Opus):
/plan add Google OAuth login
```

- En Claude Code, el **plan mode** evita ediciones mientras exploras. Pulsa `Ctrl+G` para abrir el
  plan en tu editor y ajustarlo.
- Para *features* grandes, deja que la IA **te entreviste** primero y vuelque un `SPEC.md`:

  ```text
  I want to build <X>. Interview me in detail using AskUserQuestion about implementation,
  edge cases, and tradeoffs. Then write a complete spec to SPEC.md.
  ```

  Luego abre una **sesión nueva** para ejecutar el `SPEC.md` con contexto limpio.

Comando de plantilla: [`templates/.claude/commands/plan.md`](templates/.claude/commands/plan.md).

## Paso 3 — Cuestionar el plan

Antes de aceptar el plan, somételo a una crítica de *senior engineer*:

```text
Critique this plan from a senior engineer's perspective:
1. Identify hidden assumptions
2. Flag edge cases in state management
3. Suggest 2 alternative implementations
Return revised plan with risk annotations.
```

Comando de plantilla: [`templates/.claude/commands/critique-plan.md`](templates/.claude/commands/critique-plan.md).
Lee el plan revisado **en profundidad**: este es el momento más barato para evitar que se
implemente algo sobre supuestos equivocados.

## Paso 4 — Implementar

Si estás de acuerdo con el plan, sal del plan mode y pide la implementación. Como activaste
`opusplan` en el Paso 2, la ejecución corre **automáticamente en Sonnet** —rápido y económico, sin
gastar tokens de Opus.

```text
implement the plan. verify against the success criteria, run the test suite, and fix failures.
```

La IA debe **verificar contra el plan** y mostrar evidencia, no afirmar que está hecho.

## Paso 4b — Variante: corregir un bug

Un bug fix usa el **mismo ciclo** (worktree → explore → … → PR), pero cambia el orden de juego:
**primero reproduces, luego arreglas**. Así el propio bug se convierte en tu criterio de éxito
verificable (regla #4). El flujo del día a día es:

**1. Reproduce con un test que falla** (antes de tocar el fix). Esto crea la red de seguridad y
prueba que entiendes el bug:

```text
There's a bug: <describe what happens vs. what should happen, with steps>.
First, write a failing test that reproduces it. Do NOT fix it yet — just show me the red test.
```

**2. Arregla con el cambio mínimo** (Core Invariants #2 y #3: solo lo necesario, sin refactors de
paso):

```text
Now fix the bug with the minimum change. Don't refactor unrelated code.
```

**3. Verifica**: el test que antes fallaba ahora pasa, y el resto del *safety net* sigue verde. Pide
**evidencia**, no afirmaciones:

```bash
pnpm run lint && pnpm run build && pnpm test   # backend: dotnet format && dotnet build && dotnet test
```

**4. Postmortem** (obligatorio para bugs): documenta qué pasó y por qué, para que no se repita:

```text
/postmortem <slug del bug: p.ej. "session token not refreshed after 401">
```

Esto crea `docs/postmortems/<YYYY-MM-DD>-fix-<slug>/` con *trigger*, *root cause*, *fix* y
*verification* (ver [`templates/.claude/commands/postmortem.md`](templates/.claude/commands/postmortem.md)).
A partir de aquí continúa con el **Paso 5** (pruebas) y el resto del ciclo igual que una feature.

> En un proyecto **sin tests** (brownfield), este es el mejor punto de entrada: cada bug que arreglas
> te deja un test nuevo, así que vas construyendo la red de seguridad mientras avanzas.

## Paso 5 — Pruebas

Haz pruebas **manuales** del comportamiento y corre el *safety net* de «Establecer el "safety net"»:

```bash
pnpm run lint && pnpm run build && pnpm test   # backend: dotnet format && dotnet build && dotnet test
```

Pide a la IA que **muestre la evidencia** (salida de comandos, capturas) en vez de asegurar que
funciona. Si no puedes verificarlo, no lo entregues.

## Paso 6 — Code review con IA + PR

Antes del commit/PR, haz una revisión con IA **en contexto fresco** (una sesión o subagente que no
escribió el código tiene menos sesgo):

```text
# Bundled skill — reviews the current diff in a fresh subagent:
/code-review

# Optional security pass:
/security-review
```

- Alternativa: patrón **Writer/Reviewer** — una sesión implementa, otra revisa el diff contra el
  plan.
- Matiz importante: un reviewer al que pides "encuentra fallos" **siempre** reporta algo.
  Persigue solo lo que afecta a **correctitud o a los requisitos**; lo demás suele ser
  sobre-ingeniería.
- **No hagas `/clear` aquí.** La frescura ya la da el subagente de `/code-review` (contexto limpio,
  sin sesgo); limpiar tu sesión te haría perder el plan y la implementación que necesitas para
  corregir los hallazgos y escribir el PR. El `/clear` va al **empezar** cada tarea (Paso 2), no en
  el review.
- **Modelo:** con `opusplan`, el review corre en **Sonnet** —suficiente y barato para lo rutinario.
  Solo para diffs **complejos/de alto riesgo** escala el revisor a Opus; recuerda que `/model opus`
  (o `opus[1m]`, 1M de contexto, útil únicamente con diffs **muy grandes**) **sale de opusplan**,
  así que vuelve a `/model opusplan` después.

Comando de plantilla: [`templates/.claude/commands/code-review.md`](templates/.claude/commands/code-review.md).

Luego crea el commit y el PR (usa `gh`, que es eficiente en contexto):

```bash
gh pr create --fill
```

## Paso 7 — Revisión humana

Abre el PR para revisión humana en **GitHub** o **Azure DevOps**. Usa una plantilla de PR con
checklist (tests, docs, postmortem si es bug) —
[`templates/.github/pull_request_template.md`](templates/.github/pull_request_template.md).
La IA acelera, pero la responsabilidad del merge sigue siendo humana.

```bash
# Azure DevOps equivalent:
az repos pr create --auto-complete false
```

## Paso 8 — Merge con squash

Haz **Squash and merge** para mantener un historial limpio (un commit por cambio lógico). Cuida el
texto del PR: que el título siga *conventional commits* y el cuerpo explique el qué y el porqué.

```text
feat(auth): add Google OAuth login

- adds OAuth callback handler and session refresh
- closes #123
```

> Al cerrar la tarea: si era un bug, escribe el postmortem; si añadiste funcionalidad, documenta
> bajo `docs/`. Luego `/clear` y vuelve al Paso 1 para la siguiente. Ver [Buenas prácticas](#buenas-prácticas).

---

## Buenas prácticas

- **Postmortems siempre.** Documenta cada bug/incidencia en `docs/postmortems/<YYYY-MM-DD>-fix-<slug>/`
  (trigger, root cause, fix, verification). Usa
  [`templates/.claude/commands/postmortem.md`](templates/.claude/commands/postmortem.md).
- **Documenta la funcionalidad** nueva bajo `docs/`.
- **Trata `AGENTS.md` como código:** revísalo y **pódalo** cuando la IA se equivoque; si una regla
  se ignora, probablemente el fichero es demasiado largo. Actualízalo periódicamente con decisiones
  de arquitectura.
- **Mantenlo < 200 líneas** extrayendo a sub-ficheros (`docs/Architecture.md`, `docs/Testing.md`, …)
  y referenciándolos con `@docs/...`.
- **Skills** para conocimiento que solo aplica a veces (se cargan bajo demanda y no inflan el
  contexto) — [`templates/.claude/skills/api-conventions/SKILL.md`](templates/.claude/skills/api-conventions/SKILL.md).
- **Hooks** para lo que NO puede fallar nunca: `AGENTS.md` es *advisory*, los hooks son
  deterministas (lint tras cada edit, tests al cerrar el turno) —
  [`templates/.claude/settings.json`](templates/.claude/settings.json). **Ojo:** en cuanto copies
  ese `settings.json` a `.claude/`, esos hooks corren **solos** (el linter tras cada edición y los
  tests al terminar), así que necesitas `pnpm` instalado y los scripts `lint`/`test` definidos, o
  fallarán. Adapta los comandos a tu stack. Para ajustes **solo tuyos** (no versionados), usa
  `.claude/settings.local.json`.
- **Higiene de contexto** (el recurso #1): `/clear` entre tareas no relacionadas; subagentes para
  investigar sin ensuciar el hilo; `/compact` cuando se llene; `/rewind` para deshacer.
- **MCP servers** para conectar Jira, Figma, la base de datos o el navegador (`claude mcp add`).
- **Permisos**: usa `allowlist` de comandos seguros para reducir interrupciones, pero deniega la
  lectura de secretos.
- **Nunca commitees secretos.** `.env` gitignorado, `.env.example` versionado.
- **Brownfield**: migración incremental y reversible; documenta los *gotchas* ("por qué esto es
  raro") en `docs/Architecture.md`.

## Fuentes

- [Best practices for Claude Code — Anthropic](https://code.claude.com/docs/en/best-practices)
- [Writing a good CLAUDE.md — HumanLayer](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [AGENTS.md Complete Guide for Engineering Teams (2026) — BuildBetter](https://blog.buildbetter.ai/agents-md-complete-guide-for-engineering-teams-in-2026/)
- [Is your repo ready for the AI Agents revolution? — D. Zając](https://domizajac.medium.com/is-your-repo-ready-for-the-ai-agents-revolution-926e548da528)
- [Greenfield Is Easy. Brownfield Is Where AI Gets Real — A. Montesinos](https://medium.com/@arturormk/greenfield-is-easy-brownfield-is-where-ai-software-development-gets-real-b2afad4b7f2d)
- [Opus Plan mode token savings — MindStudio](https://www.mindstudio.ai/blog/save-tokens-claude-code-opus-plan-mode)
- [Custom prompts — Codex / OpenAI](https://developers.openai.com/codex/custom-prompts)
- [Slash commands in Codex CLI — OpenAI](https://developers.openai.com/codex/cli/slash-commands)
