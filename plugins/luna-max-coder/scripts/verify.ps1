[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Contains {
    param([string]$Text, [string]$Needle, [string]$Owner)
    $haystack = [regex]::Replace($Text, '\s+', ' ')
    $target = [regex]::Replace($Needle, '\s+', ' ')
    Assert-True ($haystack.IndexOf($target, [StringComparison]::OrdinalIgnoreCase) -ge 0) "$Owner omits: $Needle"
}

$pluginDir = Split-Path -Parent $PSScriptRoot
$repoDir = Split-Path -Parent (Split-Path -Parent $pluginDir)
$manifestPath = Join-Path $pluginDir ".codex-plugin\plugin.json"
$marketplacePath = Join-Path $repoDir ".agents\plugins\marketplace.json"
$agentPath = Join-Path $pluginDir "agents\luna-max-code-writer.toml"
$skillPath = Join-Path $pluginDir "skills\code-routing\SKILL.md"
$interfacePath = Join-Path $pluginDir "skills\code-routing\agents\openai.yaml"
$readmePath = Join-Path $repoDir "README.md"
$installer = Join-Path $PSScriptRoot "install-agent.ps1"

$manifestText = Get-Content -Raw -LiteralPath $manifestPath
$manifest = $manifestText | ConvertFrom-Json
$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
$agent = Get-Content -Raw -LiteralPath $agentPath
$skill = Get-Content -Raw -LiteralPath $skillPath
$interface = Get-Content -Raw -LiteralPath $interfacePath
$readme = Get-Content -Raw -LiteralPath $readmePath

Assert-True ($manifest.name -eq "luna-max-coder") "Manifest name is incorrect."
Assert-True ($manifest.version -match '^0\.1\.0(?:\+codex\.[0-9A-Za-z.-]+)?$') "Manifest version is incorrect."
Assert-True ($manifest.interface.displayName -eq "Luna Max Coder") "Manifest display name is incorrect."
Assert-True ($marketplace.name -eq "luna-max-coder") "Marketplace name is incorrect."
Assert-True ($marketplace.plugins.Count -eq 1) "Marketplace must expose one plugin."
Assert-True ($marketplace.plugins[0].name -eq "luna-max-coder") "Marketplace plugin name is incorrect."

foreach ($exact in @(
    'name = "luna_max_code_writer"',
    'model = "gpt-5.6-luna"',
    'model_reasoning_effort = "max"'
)) { Assert-Contains $agent $exact "Agent role" }

foreach ($term in @(
    "advanced supervisor",
    "gpt-6-astra",
    "gpt-5.6-sol",
    "gpt-5.6-terra",
    "future model qualifies only",
    'Reject `gpt-5.6-luna`, unknown identities, and unranked models',
    "fail closed",
    "luna_max_code_writer",
    "max reasoning",
    "sole terminal bootstrap exception",
    "every capability the task needs",
    "does not install or guarantee them",
    "Default token-saving route",
    'fork_turns: "none"',
    "one complete handoff",
    "one batched inspection",
    "one consolidated edit",
    "one consolidated verification",
    "one targeted repair",
    "at most 1,200 characters",
    "Do not paste code, diffs, raw logs, DOM, or screenshots",
    "deterministic checks",
    "one final review",
    "minimal delta",
    "does not promise fewer raw tokens",
    "Luna is the sole lane",
    "every shell command",
    "every interactive browser action",
    "narrow read-only acceptance inspection",
    "BROWSER LIMITS",
    "public-posting",
    "Never bypass authentication"
)) { Assert-Contains $skill $term "Skill" }

foreach ($field in @(
    "OUTCOME",
    "OWNED TARGETS",
    "CONSTRAINTS AND EXCLUSIONS",
    "PERMITTED TOOLS/ACTIONS",
    "SIDE-EFFECT / CONFIRMATION STATUS",
    "CHECKS / OBSERVABLE PROOF",
    "STOP CONDITIONS",
    "HANDOFF"
)) { Assert-Contains $skill $field "Delegation brief" }

foreach ($term in @(
    "sole execution worker",
    "advanced supervisor",
    "gpt-5.6-sol",
    "Complete the batch before reporting",
    "one consolidated edit",
    "one consolidated verification command",
    "one targeted repair",
    "at most 1,200 characters",
    "Do not paste code, diffs, raw logs, DOM, or screenshots",
    "Preserve user and concurrent edits",
    "Never bypass authentication or confirmation"
)) { Assert-Contains $agent $term "Agent role" }

foreach ($term in @(
    "one fresh Luna worker",
    "one complete batch",
    "artifacts instead of transcripts",
    "one final advanced-primary review",
    "Route all code, shell, browser, Windows, web, and MCP execution through Luna",
    "allow_implicit_invocation: true"
)) { Assert-Contains $interface $term "Skill interface" }

foreach ($term in @(
    "Token-saving route",
    "one fresh Luna worker",
    "deterministic checks",
    "guarantee fewer raw tokens",
    "maximum-supervision"
)) { Assert-Contains $readme $term "README" }

foreach ($term in @("token-saving", "one fresh", "artifact evidence", "does not promise raw-token savings")) {
    Assert-Contains $manifestText $term "Manifest"
}

$coreBytes = [Text.Encoding]::UTF8.GetByteCount($skill + $agent + $interface + $manifestText)
Assert-True ($coreBytes -lt 12500) "Core routing context exceeded the 12,500-byte budget: $coreBytes"
Assert-True ([Text.Encoding]::UTF8.GetByteCount($skill) -lt 6500) "SKILL.md exceeded its context budget."
Assert-True ([Text.Encoding]::UTF8.GetByteCount($agent) -lt 3000) "Agent role exceeded its context budget."

$allOwnedText = $manifestText + "`n" + $agent + "`n" + $skill + "`n" + $interface + "`n" + $readme
foreach ($marker in @((@('TO', 'DO') -join ''), (@('FIX', 'ME') -join ''))) {
    Assert-True ($allOwnedText.IndexOf($marker, [StringComparison]::OrdinalIgnoreCase) -lt 0) "Unfinished marker found: $marker"
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("luna-max-coder-verify-" + [guid]::NewGuid().ToString("N"))
$target = Join-Path $tempRoot "agents"

try {
    $missingFailed = $false
    try { & $installer -TargetDir $target -Check } catch { $missingFailed = $true }
    Assert-True $missingFailed "Check accepted a missing agent."
    Assert-True (-not (Test-Path -LiteralPath $target)) "Check mutated a missing target."

    & $installer -TargetDir $target
    & $installer -TargetDir $target -Check
    & $installer -TargetDir $target

    $installed = Join-Path $target "luna-max-code-writer.toml"
    Add-Content -LiteralPath $installed -Value "# conflict"
    $conflictHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $installed).Hash

    $conflictFailed = $false
    try { & $installer -TargetDir $target } catch { $conflictFailed = $true }
    Assert-True $conflictFailed "Installer overwrote a conflict without -Update."
    Assert-True (((Get-FileHash -Algorithm SHA256 -LiteralPath $installed).Hash) -eq $conflictHash) "Failed install changed the conflict."

    & $installer -TargetDir $target -Update
    & $installer -TargetDir $target -Check
    $backups = @(Get-ChildItem -LiteralPath $target -Filter "luna-max-code-writer.toml.before-update.*.bak" -File)
    Assert-True ($backups.Count -eq 1) "Update did not create exactly one backup."
    Assert-True (((Get-FileHash -Algorithm SHA256 -LiteralPath $backups[0].FullName).Hash) -eq $conflictHash) "Update backup differs from the replaced file."

    $exclusiveFailed = $false
    try { & $installer -TargetDir $target -Check -Update } catch { $exclusiveFailed = $true }
    Assert-True $exclusiveFailed "Installer accepted -Check and -Update together."
} finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
    if ($resolvedTemp.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $resolvedTemp).StartsWith("luna-max-coder-verify-")) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Output "VERIFY PASSED: token-saving single-batch routing is bounded, compact, and update-safe ($coreBytes core bytes)."
