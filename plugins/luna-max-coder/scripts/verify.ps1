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
$guardrailPath = Join-Path $repoDir "benchmarks\browser-guardrail.json"
$installer = Join-Path $PSScriptRoot "install-agent.ps1"

$manifestText = Get-Content -Raw -LiteralPath $manifestPath
$manifest = $manifestText | ConvertFrom-Json
$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
$agent = Get-Content -Raw -LiteralPath $agentPath
$skill = Get-Content -Raw -LiteralPath $skillPath
$interface = Get-Content -Raw -LiteralPath $interfacePath
$readme = Get-Content -Raw -LiteralPath $readmePath
$guardrail = Get-Content -Raw -LiteralPath $guardrailPath | ConvertFrom-Json

Assert-True ($manifest.name -eq "luna-max-coder") "Manifest name is incorrect."
Assert-True ($manifest.version -match '^0\.2\.0(?:\+codex\.[0-9A-Za-z.-]+)?$') "Manifest version is incorrect."
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
    "ROUTE_ID",
    "BUDGET_LEDGER",
    "calls=0/12; failures=0/2; followups=0/1",
    "never reset after interruption",
    "checks the ledger before every tool call",
    "Only explicit user approval",
    "one complete handoff",
    "one batched inspection",
    "one consolidated edit",
    "one consolidated verification",
    "one targeted repair",
    "at most 1,200 characters",
    "Do not paste code, diffs, raw logs, DOM, or screenshots",
    "deterministic checks",
    "one final review",
    'Never send a bare `RESUME`',
    'A `STOP` instruction permits zero further tool calls',
    '`terminal=false` is only',
    "90 seconds without an observable state change",
    "4,000 characters",
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
    "EXECUTION ENVELOPE",
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
    "calls=0/12; failures=0/2; followups=0/1",
    "never reset after",
    "Check the ledger before every",
    "Only explicit",
    "Refuse a bare",
    "permits zero further tool calls",
    '`terminal=false` is only',
    "90 seconds without observable change",
    "4,000 characters",
    "one consolidated edit",
    "one consolidated verification",
    "one targeted repair",
    "at most 1,200 characters",
    "Do not paste code, diffs, raw logs, DOM, or screenshots",
    "Preserve user and concurrent edits",
    "Never bypass authentication or confirmation"
)) { Assert-Contains $agent $term "Agent role" }

foreach ($term in @(
    "one fresh Luna worker",
    "one complete batch",
    "cumulative 12-call",
    "2-failure",
    "1-correction",
    "refuse resets or bare resumes",
    "compact artifact evidence",
    "allow_implicit_invocation: true"
)) { Assert-Contains $interface $term "Skill interface" }

foreach ($term in @(
    "Token-saving route",
    "one fresh Luna worker",
    "deterministic checks",
    "guarantee fewer raw tokens",
    "maximum-supervision"
)) { Assert-Contains $readme $term "README" }

foreach ($term in @(
    "token-saving",
    "one fresh",
    "cumulative lifetime budget",
    "Resume, correction, and browser retries cannot reset",
    "artifact evidence",
    "does not promise raw-token savings"
)) {
    Assert-Contains $manifestText $term "Manifest"
}

Assert-True ($guardrail.schema_version -eq 1) "Guardrail schema version is incorrect."
$limits = $guardrail.policy
Assert-True ($limits.max_tool_calls -eq 12) "Tool-call limit drifted."
Assert-True ($limits.max_failed_tool_calls -eq 2) "Failed-tool limit drifted."
Assert-True ($limits.max_followups -eq 1) "Follow-up limit drifted."
Assert-True ($limits.no_progress_seconds -eq 90) "No-progress limit drifted."
Assert-True ($limits.max_tool_result_characters -eq 4000) "Tool-result limit drifted."
Assert-True ($guardrail.observed.tool_calls -gt $limits.max_tool_calls) "Stress trace does not exercise the tool-call limit."
Assert-True ($guardrail.observed.failed_tool_calls -gt $limits.max_failed_tool_calls) "Stress trace does not exercise the failure limit."
$expectedReplay = $guardrail.expected_replay
Assert-True ($expectedReplay.stops_no_later_than_tool_call -eq $limits.max_tool_calls) "Expected call stop differs from policy."
Assert-True ($expectedReplay.executes_no_more_than_failed_tool_calls -eq $limits.max_failed_tool_calls) "Expected failure stop differs from policy."
Assert-True (-not $expectedReplay.resume_resets_budget) "Expected replay permits a resume reset."
Assert-True (-not $expectedReplay.stop_allows_additional_tool_calls) "Expected replay permits tools after stop."
$usage = $guardrail.observed.reported_usage
Assert-True (($usage.input_tokens - $usage.cached_input_tokens) -eq $usage.uncached_input_tokens) "Guardrail uncached-input arithmetic is incorrect."
Assert-True (($usage.input_tokens + $usage.output_tokens) -eq $usage.total_tokens) "Guardrail total-token arithmetic is incorrect."
Assert-True ($usage.reasoning_output_tokens -le $usage.output_tokens) "Reasoning output must be a subset of output."

function Invoke-PolicyReplay {
    param([object[]]$Events, [object]$Limits, [string]$RouteId = "route-test")

    $state = [ordered]@{ Calls = 0; Failures = 0; Followups = 0; Rejected = 0; Terminal = $false }
    foreach ($event in $Events) {
        if ($state.Terminal) {
            $state.Rejected++
            continue
        }

        if ($event.kind -eq "tool") {
            if ($state.Calls -ge $Limits.max_tool_calls -or $state.Failures -ge $Limits.max_failed_tool_calls) {
                $state.Terminal = $true
                $state.Rejected++
            } else {
                $state.Calls++
                if ($event.status -eq "failed") { $state.Failures++ }
                if ($state.Calls -ge $Limits.max_tool_calls -or $state.Failures -ge $Limits.max_failed_tool_calls) {
                    $state.Terminal = $true
                }
            }
        } elseif ($event.kind -eq "correction") {
            $exactLedger = $event.route_id -eq $RouteId -and
                $event.calls -eq $state.Calls -and
                $event.failures -eq $state.Failures -and
                $event.followups -eq $state.Followups
            if (-not $exactLedger -or $state.Followups -ge $Limits.max_followups) {
                $state.Terminal = $true
                $state.Rejected++
            } else {
                $state.Followups++
            }
        } elseif ($event.kind -eq "resume") {
            $state.Terminal = $true
            $state.Rejected++
        } elseif ($event.kind -eq "stop") {
            $state.Terminal = $true
        } else {
            throw "Unknown replay event: $($event.kind)"
        }
    }
    return [pscustomobject]$state
}

$failureReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; status = "failed" },
    [pscustomobject]@{ kind = "tool"; status = "failed" },
    [pscustomobject]@{ kind = "tool"; status = "failed" }
) $limits
Assert-True ($failureReplay.Calls -eq 2 -and $failureReplay.Failures -eq 2 -and $failureReplay.Rejected -eq 1) "Failure ceiling can be exceeded."

$resumeReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; status = "completed" },
    [pscustomobject]@{ kind = "correction"; route_id = "route-test"; calls = 1; failures = 0; followups = 0 },
    [pscustomobject]@{ kind = "tool"; status = "completed" },
    [pscustomobject]@{ kind = "resume" },
    [pscustomobject]@{ kind = "tool"; status = "completed" }
) $limits
Assert-True ($resumeReplay.Calls -eq 2 -and $resumeReplay.Followups -eq 1 -and $resumeReplay.Rejected -eq 2) "Resume reset or follow-up accounting is unsafe."

$stopReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; status = "completed" },
    [pscustomobject]@{ kind = "stop" },
    [pscustomobject]@{ kind = "tool"; status = "completed" }
) $limits
Assert-True ($stopReplay.Calls -eq 1 -and $stopReplay.Rejected -eq 1) "Stop allowed another tool call."

$observedReplayEvents = @(1..$guardrail.observed.tool_calls | ForEach-Object {
    [pscustomobject]@{ kind = "tool"; status = "completed" }
})
$observedReplay = Invoke-PolicyReplay $observedReplayEvents $limits
Assert-True ($observedReplay.Calls -eq $limits.max_tool_calls) "Observed stress trace escaped the lifetime call ceiling."
Assert-True ($observedReplay.Rejected -eq ($guardrail.observed.tool_calls - $limits.max_tool_calls)) "Observed stress trace rejection count is incorrect."

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

Write-Output "VERIFY PASSED: routing has a cumulative lifetime budget, deterministic replay, compact context, and update safety ($coreBytes core bytes)."
