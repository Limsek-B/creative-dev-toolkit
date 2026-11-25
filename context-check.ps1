[CmdletBinding(DefaultParameterSetName = 'Record')]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Files,

    [Parameter(Mandatory = $true, ParameterSetName = 'Check')]
    [string]$Check
)

$ErrorActionPreference = 'Stop'

function Get-ContextFileHash {
    param([Parameter(Mandatory = $true)][string]$FullPath)
    if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $FullPath -Algorithm SHA256).Hash
}

try {
    $recording = $PSCmdlet.ParameterSetName -eq 'Record'
    if (-not $recording) {
        $manifest = Get-Content -LiteralPath $Check -Raw | ConvertFrom-Json
        if ($manifest.version -ne 1 -or $manifest.files -isnot [array] -or
            $manifest.files.Count -ne $Files.Count) {
            throw 'Invalid manifest or different file list.'
        }
    }

    $entries = @()
    $stale = $false
    for ($index = 0; $index -lt $Files.Count; $index++) {
        $file = $Files[$index]
        $hash = Get-ContextFileHash -FullPath $file
        if ($recording) {
            if (-not $hash) { throw "Missing file: $file" }
            $entries += [ordered]@{ path = $file; sha256 = $hash }
            continue
        }

        $entry = $manifest.files[$index]
        if ($entry.path -cne $file -or $entry.sha256 -isnot [string] -or
            $entry.sha256 -notmatch '^[0-9a-f]{64}$') {
            throw 'Invalid manifest or different file list.'
        }
        if ($hash -ne $entry.sha256) {
            Write-Output "Changed or missing: $file"
            $stale = $true
        }
    }

    if ($recording) {
        [ordered]@{ version = 1; files = $entries } | ConvertTo-Json -Depth 4
    }
    elseif ($stale) {
        exit 1
    }
    else {
        Write-Output 'Context files match.'
    }
    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 2
}
