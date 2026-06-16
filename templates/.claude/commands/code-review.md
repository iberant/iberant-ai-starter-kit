---
description: Review the current diff in a fresh perspective for correctness gaps
---

Review the current git diff as an independent reviewer who did NOT write this code.

Focus, in order:
1. Correctness bugs, race conditions, and unhandled error/edge cases.
2. Whether every requirement in the plan/spec is actually implemented.
3. Anything changed outside the task's stated scope.

Report only findings that affect correctness or the stated requirements — not style
preferences (those are the linter's job). For each finding give `file:line`, the problem,
and a concrete fix. If the diff is sound, say so plainly.

Tip: the bundled `/code-review` skill runs this in a fresh subagent; prefer it when available.
