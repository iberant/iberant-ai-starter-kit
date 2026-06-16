---
name: postmortem
description: Scaffold a dated postmortem folder under docs/postmortems/
---

Create a postmortem for the bug/issue just fixed: $ARGUMENTS

1. Create a folder `docs/postmortems/<YYYY-MM-DD>-fix-<short-slug>/`.
2. Add `README.md` covering: Trigger, Root Cause, Fix, Verification, Artifacts.
3. Base it on what actually happened in this session — the real error, the real fix, and
   the command/test that proves it. Keep it short and factual.
4. Place any DB scripts or other artifacts the fix required in the same folder.
