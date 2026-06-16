# iberant-ai-starter-kit

Un *starter kit* para dejar cualquier proyecto —nuevo (*greenfield*) o existente
(*brownfield*)— listo para trabajar con asistentes de IA de código (Claude Code y Codex) de
forma productiva y segura.

Incluye **una guía paso a paso** y un conjunto de **plantillas listas para copiar** (instrucciones
para el agente, scripts de setup, slash commands, hooks, plantilla de PR y postmortems).

## ¿Para quién es?

Para cualquier equipo que quiera adoptar un asistente de IA con un flujo de trabajo disciplinado:
contexto persistente para el agente, una red de verificación (lint/test/CI) y un ciclo
planificar → cuestionar → implementar → revisar.

**¿Nuevo en IA por terminal?** No hace falta experiencia previa. Necesitarás instalar unas
herramientas (git, Node/pnpm o .NET, `gh`/`az` y **Claude Code** o **Codex**) — la sección
[Requisitos e instalación](STARTUP.md#requisitos-e-instalación) lo explica desde cero. Y si te
topas con jerga (token, modelo, plan mode, hook…), el
[glosario mínimo](STARTUP.md#qué-es-glosario-mínimo) la define en una línea.

## 👉 Empieza por la guía

La guía completa está en **[STARTUP.md](STARTUP.md)**, dividida en dos partes:

**Parte A — Configuración inicial (una sola vez, sin orden estricto)**
- Requisitos e instalación (instalar y autenticar las herramientas)
- Windows: developer mode + symlinks
- Establecer el "safety net" (comandos, lint, tests, CI, secretos)
- Inicializar `AGENTS.md` / `CLAUDE.md` + reglas core (Karpathy)

**Parte B — Ciclo por cada feature / bug / issue (recurrente)**
- Paso 1 — Crear un worktree
- Paso 2 — Explorar y planificar (activa `opusplan`: plan→Opus, impl→Sonnet)
- Paso 3 — Cuestionar el plan
- Paso 4 — Implementar
- Paso 5 — Pruebas
- Paso 6 — Code review con IA + PR
- Paso 7 — Revisión humana (GitHub / Azure DevOps)
- Paso 8 — Merge con squash

Más [Buenas prácticas](STARTUP.md#buenas-prácticas).

## 🎬 ¿Prefieres verlo en acción?

[**WALKTHROUGH.md**](WALKTHROUGH.md) simula una sesión completa de principio a fin (construyendo un
buscaminas HTML5) para que veas **qué esperar en cada paso**: cuándo activar `opusplan`, cómo Claude
te hace preguntas antes de planificar, cómo apruebas el plan y empieza la implementación, y qué
evidencia muestra al final. Ideal si es tu primera vez.

> **Convención del proyecto (idioma):** todo el **código, comentarios, identificadores, mensajes
> de log y mensajes de commit se escriben en inglés**. Escribir el código en inglés lo mantiene
> consistente y legible para cualquier herramienta o colaborador. La documentación para el equipo
> (guías como esta) puede ir en español.

## ✅ Checklist por cada feature / bug / issue

Flujo recurrente (Parte B). Cópialo en cada tarea y síguelo en orden. El detalle de cada paso
está en [STARTUP.md](STARTUP.md).

```
worktree → explore → plan → implement → review → PR → human-review → merge
```

- [ ] **Worktree** — `git worktree add ../app-<task> -b feature/<task>` y trabaja dentro (`pwd`).
- [ ] **Explore** — `/model opusplan` (plan→Opus, impl→Sonnet), luego en plan mode la IA lee el código (sin editar).
- [ ] **Plan** — `/plan <task>`; para features grandes, entrevista → `SPEC.md`.
- [ ] **Critique** — `/critique-plan`; lee el plan revisado a fondo antes de aceptar.
- [ ] **Implement** — sal del plan mode e implementa (corre en Sonnet); verifica contra el plan.
- [ ] **Test** — pruebas manuales + `lint`/`build`/`test`; la IA muestra evidencia.
- [ ] **Review (IA)** — `/code-review` (y `/security-review`) en contexto fresco.
- [ ] **PR** — `gh pr create --fill` (o `az repos pr create`).
- [ ] **Human review** — revisión humana en GitHub / Azure DevOps con checklist de PR.
- [ ] **Merge** — *Squash and merge*; postmortem si fue bug; docs si fue feature; `git worktree remove`.

> **¿Es un bug?** Mismo checklist, pero en **Implement** invierte el orden: primero escribe un
> **test que falle** que reproduzca el bug, luego el fix mínimo, y cierra con `/postmortem`. Detalle
> en el [Paso 4b](STARTUP.md#paso-4b--variante-corregir-un-bug).

## Plantillas (`templates/`)

Cópialas a la raíz de tu proyecto y adáptalas a tu stack:

```
templates/
├── AGENTS.md                         # Source of truth for AI agents (<200 lines)
├── CLAUDE.md                         # Symlink -> AGENTS.md
├── .env.example                      # Secret placeholders (commit this, not .env)
├── .gitignore                        # Ignores secrets + AI local overrides
├── docs/
│   ├── Architecture.md               # Sub-file: stack, modules, decisions, gotchas
│   └── postmortems/
│       └── 2026-05-04-fix-example-slug/README.md
├── examples/                         # Stack-specific config examples
│   ├── vite-react/.env.example       # Vite/React env vars (VITE_ prefix)
│   └── aspnet-core/                  # appsettings.json + appsettings.Development.json
├── .claude/
│   ├── settings.json                 # Permissions + hooks (lint on edit, tests on stop)
│   ├── commands/                     # plan, critique-plan, code-review, postmortem
│   └── skills/api-conventions/SKILL.md
├── scripts/
│   ├── link-agents.sh                # ln -s AGENTS.md CLAUDE.md (macOS/Linux)
│   ├── link-agents.ps1               # symlink on Windows
│   └── setup-windows-dev.ps1         # enable dev mode + git symlinks
└── .github/
    └── pull_request_template.md      # PR checklist
```

## Uso rápido

```bash
# macOS / Linux
# 0. First time only: install + authenticate the tools (see STARTUP.md → "Requisitos e instalación").
#    git, Node/pnpm (or .NET), gh/az, and Claude Code / Codex.
# 1. Copy the templates you need into your project root, then link CLAUDE.md -> AGENTS.md:
./templates/scripts/link-agents.sh
# 2. Edit AGENTS.md and docs/Architecture.md for your project.
```

```powershell
# Windows (PowerShell)
# 0a. First time only: install + authenticate the tools (see STARTUP.md → "Requisitos e instalación").
# 0b. One-time: enable Developer Mode + git symlinks (run as Administrator):
.\templates\scripts\setup-windows-dev.ps1
# 1. Copy the templates, then link CLAUDE.md -> AGENTS.md:
.\templates\scripts\link-agents.ps1
# 2. Edit AGENTS.md and docs\Architecture.md for your project.
```

Lee **[STARTUP.md](STARTUP.md)** para el detalle completo.

## Licencia

Copyright © 2026 **IBERANT SOLUTIONS S.L.** Todos los derechos reservados.

Software propietario. Ninguna parte de este repositorio puede usarse, copiarse, modificarse ni
distribuirse sin el permiso previo y por escrito de IBERANT SOLUTIONS S.L. Consulta el fichero
[LICENSE](LICENSE).
