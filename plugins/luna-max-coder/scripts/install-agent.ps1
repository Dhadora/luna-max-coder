[CmdletBinding()]
param(
    [string]$TargetDir,
    [switch]$Check,
    [switch]$Update
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Check -and $Update) {
    throw "Use either -Check or -Update, not both."
}

$pluginDir = Split-Path -Parent $PSScriptRoot
$source = Join-Path $pluginDir "agents\luna-max-code-writer.toml"

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Shipped Luna agent template is missing: $source"
}

$sourceItem = Get-Item -LiteralPath $source -Force
if (($sourceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
    throw "Shipped Luna agent template must not be a reparse point: $source"
}

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $TargetDir = Join-Path $env:CODEX_HOME "agents"
    } elseif (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $TargetDir = Join-Path $env:USERPROFILE ".codex\agents"
    } else {
        throw "Neither CODEX_HOME nor USERPROFILE is available; pass -TargetDir explicitly."
    }
}

$targetFull = [IO.Path]::GetFullPath($TargetDir)
$targetRoot = [IO.Path]::GetPathRoot($targetFull)
if ($targetFull.TrimEnd('\') -eq $targetRoot.TrimEnd('\')) {
    throw "Refusing to use a filesystem root as the agent target directory: $targetFull"
}

$destination = Join-Path $targetFull "luna-max-code-writer.toml"

function Test-ExactTemplate {
    if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
        return $false
    }

    $destinationItem = Get-Item -LiteralPath $destination -Force
    if (($destinationItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "Destination must not be a reparse point: $destination"
    }

    $expected = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    $actual = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    return $expected -eq $actual
}

if ($Check) {
    if (-not (Test-Path -LiteralPath $targetFull -PathType Container)) {
        throw "Luna agent directory is missing: $targetFull"
    }
    if (-not (Test-ExactTemplate)) {
        throw "Luna agent is missing or differs from the shipped template: $destination"
    }
    Write-Output "CHECK PASSED: Luna Max agent exactly matches $source"
    return
}

if (-not (Test-Path -LiteralPath $targetFull)) {
    $null = New-Item -ItemType Directory -Path $targetFull
}

$targetItem = Get-Item -LiteralPath $targetFull -Force
if (-not $targetItem.PSIsContainer -or
    (($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) {
    throw "Target must be a real directory, not a file or reparse point: $targetFull"
}

if (Test-Path -LiteralPath $destination) {
    if (Test-ExactTemplate) {
        Write-Output "ALREADY CURRENT: $destination"
        return
    }
    if (-not $Update) {
        throw "Refusing to overwrite a different Luna agent file without -Update: $destination"
    }

    $backup = $destination + ".before-update." +
        (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssfffZ") + "." +
        [guid]::NewGuid().ToString("N") + ".bak"
    $staged = Join-Path $targetFull (".luna-max-code-writer." + [guid]::NewGuid().ToString("N") + ".tmp")
    try {
        [IO.File]::Copy($source, $staged, $false)
        [IO.File]::Replace($staged, $destination, $backup, $true)
    } finally {
        if (Test-Path -LiteralPath $staged) {
            Remove-Item -LiteralPath $staged -Force
        }
    }

    if (-not (Test-ExactTemplate)) {
        throw "Post-update exactness check failed: $destination"
    }
    Write-Output "UPDATE PASSED: $destination"
    Write-Output "BACKUP: $backup"
    return
}

$staged = Join-Path $targetFull (".luna-max-code-writer." + [guid]::NewGuid().ToString("N") + ".tmp")
try {
    [IO.File]::Copy($source, $staged, $false)
    [IO.File]::Move($staged, $destination)
} finally {
    if (Test-Path -LiteralPath $staged) {
        Remove-Item -LiteralPath $staged -Force
    }
}

if (-not (Test-ExactTemplate)) {
    throw "Post-install exactness check failed: $destination"
}

Write-Output "INSTALL PASSED: $destination"
