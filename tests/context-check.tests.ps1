$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$script = Join-Path $root 'context-check.ps1'
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $fixture | Out-Null
Push-Location -LiteralPath $fixture

try {
    Copy-Item -LiteralPath (Join-Path $root 'examples/handoff.md') -Destination 'handoff.md'
    & $script -Files handoff.md | Set-Content -Encoding utf8 manifest.json
    if ($LASTEXITCODE -ne 0) { throw 'Failed to record the example.' }

    $output = & $script -Files handoff.md -Check manifest.json
    if ($LASTEXITCODE -ne 0 -or $output -ne 'Context files match.') {
        throw 'Expected an unchanged handoff to match.'
    }

    Add-Content -LiteralPath handoff.md -Value 'A new task.'
    $output = & $script -Files handoff.md -Check manifest.json
    if ($LASTEXITCODE -ne 1 -or $output -ne 'Changed or missing: handoff.md') {
        throw 'Expected a changed handoff to be reported.'
    }

    Move-Item -LiteralPath handoff.md -Destination moved.md
    $output = & $script -Files handoff.md -Check manifest.json
    if ($LASTEXITCODE -ne 1 -or $output -ne 'Changed or missing: handoff.md') {
        throw 'Expected a missing handoff to be reported.'
    }

    Copy-Item -LiteralPath moved.md -Destination 'notes [draft].md'
    & $script -Files 'notes [draft].md',moved.md | Set-Content -Encoding utf8 manifest.json
    if ($LASTEXITCODE -ne 0) { throw 'Failed to record two literal paths.' }
    $output = & $script -Files 'notes [draft].md',moved.md -Check manifest.json
    if ($LASTEXITCODE -ne 0 -or $output -ne 'Context files match.') {
        throw 'Expected both files to match.'
    }

    & $script -Files moved.md,'notes [draft].md' -Check manifest.json
    if ($LASTEXITCODE -ne 2) { throw 'Expected a different file order to be rejected.' }

    Set-Content -LiteralPath manifest.json -Value 'invalid JSON'
    & $script -Files moved.md -Check manifest.json
    if ($LASTEXITCODE -ne 2) { throw 'Expected malformed JSON to be rejected.' }

    & $script -Files handoff.md
    if ($LASTEXITCODE -ne 2) { throw 'Expected recording a missing file to fail.' }

    'Passed all 7 context-check scenarios.'
}
finally {
    Pop-Location
    foreach ($name in 'handoff.md', 'moved.md', 'notes [draft].md', 'manifest.json') {
        $file = Join-Path $fixture $name
        if (Test-Path -LiteralPath $file) { Remove-Item -LiteralPath $file }
    }
    Remove-Item -LiteralPath $fixture
}
