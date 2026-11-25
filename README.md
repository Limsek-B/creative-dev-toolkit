# Creative Dev Toolkit

`context-check.ps1` records SHA-256 fingerprints for the files you hand to an AI assistant. Check the same files when you resume work to see whether the saved context has changed, including edits that were never committed.

## Install

Download this repository and open PowerShell in its root. The script runs in Windows PowerShell 5.1 or PowerShell 7. It uses built-in commands and works without Git or network access.

## Run the example

Run these commands from the repository root in PowerShell.

```powershell
./context-check.ps1 -Files examples/handoff.md | Set-Content -Encoding utf8 context.json
./context-check.ps1 -Files examples/handoff.md -Check context.json
```

The check prints `Context files match.` and exits with code 0. After you edit the example handoff, run the second command again. It identifies the changed file and exits with code 1. Input or manifest errors exit with code 2. In PowerShell, read the code with `$LASTEXITCODE`.

Pass more files as a comma-separated list, such as `-Files project-state.md,handoff.md`. Use the same path spellings, order, and working directory for both commands. The manifest stores the paths you pass and their hashes. Use relative paths if you plan to share it.

When you update the context deliberately, record a new manifest. The check covers byte-for-byte agreement with the recorded files.

## Tests

```powershell
./tests/context-check.tests.ps1
```
