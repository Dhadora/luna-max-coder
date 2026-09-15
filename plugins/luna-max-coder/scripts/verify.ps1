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

function Assert-NotContains {
    param([string]$Text, [string]$Needle, [string]$Owner)
    $haystack = [regex]::Replace($Text, '\s+', ' ')
    $target = [regex]::Replace($Needle, '\s+', ' ')
    Assert-True ($haystack.IndexOf($target, [StringComparison]::OrdinalIgnoreCase) -lt 0) "$Owner still contains forbidden routing: $Needle"
}

function Get-WindowsUtf8ByteCount {
    param([string]$Text)
    $windowsText = [regex]::Replace($Text, '\r?\n', "`r`n")
    return [Text.Encoding]::UTF8.GetByteCount($windowsText)
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
Assert-True ($manifest.version -match '^0\.3\.0(?:\+codex\.[0-9A-Za-z.-]+)?$') "Manifest version is incorrect."
Assert-True ($manifest.interface.displayName -eq "Luna Max Coder") "Manifest display name is incorrect."
Assert-True ($marketplace.name -eq "luna-max-coder") "Marketplace name is incorrect."
Assert-True ($marketplace.plugins.Count -eq 1) "Marketplace must expose one plugin."
Assert-True ($marketplace.plugins[0].name -eq "luna-max-coder") "Marketplace plugin name is incorrect."

foreach ($term in @(
    "ROUTE_KIND",
    "CODE_EDIT",
    "BROWSER_ACTION",
    "primary owns shell, SSH",
    "tests and builds",
    '`apply_patch` only',
    "browser tools only"
)) { Assert-Contains ($skill + "`n" + $agent) $term "Routing scope" }

foreach ($term in @(
    "Luna is the sole lane for",
    "every shell command",
    "routine MCP reads",
    "image generation"
)) { Assert-NotContains $skill $term "Skill" }

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
    "primary runs this check",
    "exact role, model, and effort",
    "does not install or guarantee them",
    'exactly one `ROUTE_KIND`',
    "If a task contains neither, do not spawn Luna",
    "primary owns shell, SSH",
    "tests and builds",
    "Luna never performs discovery or self-bootstrap",
    '`apply_patch` only',
    'only nested operation is `apply_patch`',
    'must not use `exec_command`',
    "primary reviews the diff and runs every check",
    "browser tools only",
    'fork_turns: "none"',
    "ROUTE_ID",
    "BUDGET_LEDGER",
    "calls=0/2; failures=0/2; followups=0/1",
    "calls=0/8; failures=0/2; followups=0/1",
    "checks the route kind, permitted tool family, and ledger before every call",
    "Count every issued call and every failed result",
    "Never exclude a failure",
    "Limits never reset after",
    "Only explicit user approval",
    "zero additional calls",
    "Never replace the worker to reset limits",
    "A successful route is terminal",
    '`terminal=false` is allowed only',
    "90 seconds without an observable state change",
    "4,000 characters",
    "at most 1,000 characters",
    "artifact evidence",
    "primary performs the final review and all verification",
    'Do not mention `$code-routing`',
    "BROWSER LIMITS",
    "public-posting",
    "Never bypass authentication"
)) { Assert-Contains $skill $term "Skill" }

foreach ($field in @(
    "OUTCOME",
    "ROUTE_KIND",
    "OWNED TARGETS",
    "CURRENT CONTEXT",
    "CONSTRAINTS AND EXCLUSIONS",
    "EXECUTION ENVELOPE",
    "SIDE-EFFECT / CONFIRMATION STATUS",
    "OBSERVABLE PROOF",
    "STOP CONDITIONS"
)) { Assert-Contains $skill $field "Delegation brief" }

foreach ($term in @(
    "limited to one code patch or one browser",
    "accepted advanced supervisor",
    "discovery, reads, shell, SSH, tests and builds",
    "Never load SKILL.md",
    '`apply_patch` only',
    'one nested operation: `apply_patch`',
    'never use `exec_command`',
    "browser tools only",
    "calls=0/2; failures=0/2; followups=0/1",
    "calls=0/8; failures=0/2; followups=0/1",
    "Count every issued call and every failed result",
    "never exclude a failure",
    "Stop immediately at a limit",
    "Counters never reset after",
    "Only explicit user approval",
    'Refuse bare `RESUME`',
    '`STOP` permits zero further tool calls',
    "disallowed tool request is terminal",
    "A successful route is terminal",
    'Use `terminal=false` only',
    "90 seconds without observable progress",
    "4,000 characters",
    "at most 1,000 characters",
    "Preserve user and concurrent edits",
    "Never bypass authentication or confirmation"
)) { Assert-Contains $agent $term "Agent role" }

foreach ($term in @(
    "keep discovery, reads, shell, SSH, tests, research, MCP",
    "one exact code edit",
    "one bounded browser action",
    "allow_implicit_invocation: false"
)) { Assert-Contains $interface $term "Skill interface" }

foreach ($term in @(
    "Token-saving route",
    "CODE_EDIT",
    "BROWSER_ACTION",
    "apply_patch",
    "shell and SSH",
    "tests and builds",
    "does not start Luna",
    '2 `apply_patch` calls',
    "8 browser-tool calls",
    "historical data"
)) { Assert-Contains $readme $term "README" }

foreach ($term in @(
    "only code edits and browser actions",
    "shell and SSH",
    "one exact code patch",
    "one bounded browser interaction",
    "operational tasks remain with the primary"
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
    param(
        [object[]]$Events,
        [object]$Limits,
        [string]$RouteId = "route-test",
        [string]$RouteKind = "",
        [string]$AllowedToolFamily = ""
    )

    $state = [ordered]@{ Calls = 0; Failures = 0; Followups = 0; Rejected = 0; Terminal = $false }
    foreach ($event in $Events) {
        if ($state.Terminal) {
            $state.Rejected++
            continue
        }

        if ($event.kind -eq "tool") {
            $eventToolFamily = if ($event.PSObject.Properties.Name -contains "tool_family") { [string]$event.tool_family } else { "" }
            if ($AllowedToolFamily -and $eventToolFamily -ne $AllowedToolFamily) {
                $state.Terminal = $true
                $state.Rejected++
            } elseif ($state.Calls -ge $Limits.max_tool_calls -or $state.Failures -ge $Limits.max_failed_tool_calls) {
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
            $eventRouteKind = if ($event.PSObject.Properties.Name -contains "route_kind") { [string]$event.route_kind } else { "" }
            $exactLedger = $event.route_id -eq $RouteId -and
                $event.calls -eq $state.Calls -and
                $event.failures -eq $state.Failures -and
                $event.followups -eq $state.Followups -and
                (-not $RouteKind -or $eventRouteKind -eq $RouteKind)
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

$codeLimits = [pscustomobject]@{ max_tool_calls = 2; max_failed_tool_calls = 2; max_followups = 1 }
$browserLimits = [pscustomobject]@{ max_tool_calls = 8; max_failed_tool_calls = 2; max_followups = 1 }

$operationalCodeReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; tool_family = "shell"; status = "completed" }
) $codeLimits "code-route" "CODE_EDIT" "apply_patch"
Assert-True ($operationalCodeReplay.Calls -eq 0 -and $operationalCodeReplay.Rejected -eq 1 -and $operationalCodeReplay.Terminal) "CODE_EDIT issued an operational tool call."

$operationalBrowserReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; tool_family = "shell"; status = "completed" }
) $browserLimits "browser-route" "BROWSER_ACTION" "browser"
Assert-True ($operationalBrowserReplay.Calls -eq 0 -and $operationalBrowserReplay.Rejected -eq 1 -and $operationalBrowserReplay.Terminal) "BROWSER_ACTION issued a non-browser tool call."

$codeBudgetReplay = Invoke-PolicyReplay @(
    [pscustomobject]@{ kind = "tool"; tool_family = "apply_patch"; status = "completed" },
    [pscustomobject]@{ kind = "tool"; tool_family = "apply_patch"; status = "completed" },
    [pscustomobject]@{ kind = "tool"; tool_family = "apply_patch"; status = "completed" }
) $codeLimits "code-route" "CODE_EDIT" "apply_patch"
Assert-True ($codeBudgetReplay.Calls -eq 2 -and $codeBudgetReplay.Rejected -eq 1) "CODE_EDIT exceeded its two-patch budget."

$browserBudgetEvents = @(1..9 | ForEach-Object {
    [pscustomobject]@{ kind = "tool"; tool_family = "browser"; status = "completed" }
})
$browserBudgetReplay = Invoke-PolicyReplay $browserBudgetEvents $browserLimits "browser-route" "BROWSER_ACTION" "browser"
Assert-True ($browserBudgetReplay.Calls -eq 8 -and $browserBudgetReplay.Rejected -eq 1) "BROWSER_ACTION exceeded its eight-call budget."

$coreBytes = Get-WindowsUtf8ByteCount ($skill + $agent + $interface + $manifestText)
Assert-True ($coreBytes -lt 12500) "Core routing context exceeded the 12,500-byte budget: $coreBytes"
Assert-True ((Get-WindowsUtf8ByteCount $skill) -lt 6500) "SKILL.md exceeded its Windows context budget."
Assert-True ((Get-WindowsUtf8ByteCount $agent) -lt 3000) "Agent role exceeded its Windows context budget."

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

Write-Output "VERIFY PASSED: Luna is restricted to code patches and browser actions with lane budgets, deterministic replay, compact context, and update safety ($coreBytes core bytes)."
