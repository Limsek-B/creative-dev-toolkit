# Creative Dev Toolkit

**Catch stale AI handoffs before your next session.**

You save a handoff at the end of an AI-assisted session. Later, you update a decision or change the project state. The old handoff can still read as if it’s current. Record the files your handoff depends on, then check them before you resume. If a file changed or disappeared, the script names it so you know what to revisit.

`context-check.ps1` compares SHA-256 fingerprints of the files you choose. It detects uncommitted edits and works offline, with or without Git.

## Install

Download this repository and open PowerShell in its root. The script uses built-in commands and runs on Windows PowerShell 5.1 or PowerShell 7.

## Try the handoff check

Record the example handoff and check it immediately.

```powershell
./context-check.ps1 -Files examples/handoff.md | Set-Content -Encoding utf8 context.json
./context-check.ps1 -Files examples/handoff.md -Check context.json
```

```text
Context files match.
```

Change one line in `examples/handoff.md` and rerun just the check command.

```text
Changed or missing: examples/handoff.md
```

Read the result with `$LASTEXITCODE`. A match returns `0`, a changed or missing file returns `1`, and an input or manifest error returns `2`.

Pass multiple files as a comma-separated list, such as `-Files project-state.md,handoff.md`. Use the same path spellings, order, and working directory for both commands. The manifest stores the paths you pass and their hashes. Use relative paths if you plan to share it.

Record a new manifest when you deliberately update the handoff and its source files. A match means the selected files agree byte for byte with the recorded versions.

## Tests

Seven scenarios passed on Windows PowerShell 5.1 and PowerShell 7.

```powershell
./tests/context-check.tests.ps1
```
