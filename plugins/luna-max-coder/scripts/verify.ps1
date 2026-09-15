[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-TextContains {
    param([string]$Text, [string]$Needle, [string]$Message)
    $normalizedText = [regex]::Replace($Text, '\s+', ' ')
    $normalizedNeedle = [regex]::Replace($Needle, '\s+', ' ')
    Assert-True ($normalizedText.IndexOf($normalizedNeedle, [StringComparison]::OrdinalIgnoreCase) -ge 0) $Message
}

function Assert-TextNotContains {
    param([string]$Text, [string]$Needle, [string]$Message)
    $normalizedText = [regex]::Replace($Text, '\s+', ' ')
    $normalizedNeedle = [regex]::Replace($Needle, '\s+', ' ')
    Assert-True ($normalizedText.IndexOf($normalizedNeedle, [StringComparison]::OrdinalIgnoreCase) -lt 0) $Message
}

$pluginDir = Split-Path -Parent $PSScriptRoot
$repoDir = Split-Path -Parent (Split-Path -Parent $pluginDir)
$manifestPath = Join-Path $pluginDir ".codex-plugin\plugin.json"
$marketplacePath = Join-Path $repoDir ".agents\plugins\marketplace.json"
$agentPath = Join-Path $pluginDir "agents\luna-max-code-writer.toml"
$skillPath = Join-Path $pluginDir "skills\code-routing\SKILL.md"
$interfacePath = Join-Path $pluginDir "skills\code-routing\agents\openai.yaml"
$installer = Join-Path $PSScriptRoot "install-agent.ps1"

$manifestText = Get-Content -Raw -LiteralPath $manifestPath
$manifest = $manifestText | ConvertFrom-Json
Assert-True ($manifest.name -eq "luna-max-coder") "Manifest name is incorrect."
Assert-True ($manifest.version -match '^0\.1\.0(?:\+codex\.[0-9A-Za-z.-]+)?$') "Manifest version is incorrect."
Assert-True ($manifest.interface.displayName -eq "Luna Max Coder") "Manifest display name is incorrect."

$marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
Assert-True ($marketplace.name -eq "luna-max-coder") "Marketplace name is incorrect."
Assert-True ($marketplace.plugins.Count -eq 1) "Marketplace must expose exactly one plugin."
Assert-True ($marketplace.plugins[0].name -eq "luna-max-coder") "Marketplace plugin name is incorrect."

$manifestPrompts = @($manifest.interface.defaultPrompt) -join " "
Assert-TextContains ([string]$manifest.description) "advanced-supervisor" "Manifest description omits the supervisor role."
Assert-TextContains ([string]$manifest.description) "non-Luna" "Manifest description omits the non-Luna supervisor boundary."
Assert-TextContains ([string]$manifest.interface.shortDescription) "ranked" "Manifest short description omits supervisor ranking."
Assert-TextContains ([string]$manifest.interface.longDescription) "non-Luna" "Manifest long description omits the non-Luna supervisor boundary."
Assert-TextContains ([string]$manifest.interface.longDescription) "gpt-6-astra" "Manifest long description omits the accepted supervisor families."
Assert-TextContains ([string]$manifest.interface.longDescription) "gpt-5.6-sol" "Manifest long description omits the accepted supervisor families."
Assert-TextContains ([string]$manifest.interface.longDescription) "gpt-5.6-terra" "Manifest long description omits the accepted supervisor families."
Assert-TextContains ([string]$manifest.interface.longDescription) "future model qualifies" "Manifest long description omits future-model ranking."
Assert-TextContains ([string]$manifest.interface.longDescription) "Unknown, unranked, or Luna primaries fail closed" "Manifest long description omits rejected supervisor identities."
Assert-TextContains ([string]$manifest.interface.longDescription) "every shell or terminal command" "Manifest long description omits terminal routing."
Assert-TextContains ([string]$manifest.interface.longDescription) "interactive browser" "Manifest long description omits browser routing."
Assert-TextContains ([string]$manifest.interface.longDescription) "sole terminal exception" "Manifest long description omits the bootstrap exception."
Assert-TextContains ([string]$manifest.interface.longDescription) "narrow read-only acceptance inspection" "Manifest long description omits primary acceptance scope."
Assert-TextContains ([string]$manifest.interface.longDescription) "routes existing capabilities" "Manifest long description omits capability routing."
Assert-TextContains $manifestPrompts "exposed Codex metadata" "Manifest prompt omits supervisor preflight."
Assert-TextContains $manifestPrompts "stop" "Manifest prompt omits fail-closed behavior."

$agent = Get-Content -Raw -LiteralPath $agentPath
$skill = Get-Content -Raw -LiteralPath $skillPath
$interface = Get-Content -Raw -LiteralPath $interfacePath
$readme = Get-Content -Raw -LiteralPath (Join-Path $repoDir "README.md")

Assert-True ($agent.Contains('name = "luna_max_code_writer"')) "Agent role name is not pinned."
Assert-True ($agent.Contains('model = "gpt-5.6-luna"')) "Agent model is not Luna."
Assert-True ($agent.Contains('model_reasoning_effort = "max"')) "Agent effort is not max."
Assert-TextContains $agent "sole execution worker" "Agent role is not the sole execution worker."
Assert-TextContains $agent "advanced supervisor" "Agent role omits the supervisor boundary."
Assert-TextContains $agent "non-Luna primary" "Agent role omits the non-Luna supervisor requirement."
Assert-TextContains $agent "primary's reasoning effort does not change this ranking" "Agent role incorrectly couples supervisor ranking to effort."
Assert-TextContains $agent "future model" "Agent role omits future-model ranking."
Assert-TextContains $agent "more capable than" "Agent role omits the future-model capability comparison."
Assert-TextContains $agent "Reject" "Agent role omits rejected supervisor identities."
Assert-TextContains $agent "unknown identities" "Agent role omits unknown-identity rejection."
Assert-TextContains $agent "unranked models" "Agent role omits unranked-model rejection."
Assert-TextContains $agent "Do not infer that every non-Luna model is advanced" "Agent role overclaims non-Luna models."

Assert-TextContains $skill "advanced supervisor" "Skill omits primary supervisor ownership."
Assert-TextContains $skill "non-Luna primary" "Skill omits the non-Luna supervisor requirement."
Assert-TextContains $skill "exposed Codex product or runtime metadata" "Skill omits supervisor identity preflight."
Assert-TextContains $skill "gpt-5.6-luna" "Skill omits the Luna identity guard."
Assert-TextContains $skill "fail closed" "Skill omits fail-closed behavior."
Assert-TextContains $skill "gpt-6-astra" "Skill omits an accepted advanced supervisor family."
Assert-TextContains $skill "gpt-5.6-sol" "Skill omits an accepted advanced supervisor family."
Assert-TextContains $skill "gpt-5.6-terra" "Skill omits an accepted advanced supervisor family."
Assert-TextContains $skill "future model qualifies only" "Skill omits future-model ranking."
Assert-TextContains $skill "more capable than" "Skill omits the future-model capability comparison."
Assert-TextContains $skill 'Reject `gpt-5.6-luna`, unknown identities, and unranked models' "Skill does not reject invalid supervisor identities."
Assert-TextContains $skill "Do not infer that every non-Luna model is advanced" "Skill overclaims non-Luna models."
Assert-TextContains $skill "identity or ranking is not exposed" "Skill does not handle missing supervisor metadata."
Assert-TextContains $skill "never silently switch" "Skill permits an unsafe primary switch."
Assert-TextContains $skill "add a reviewer" "Skill permits a fixed reviewer fallback."
Assert-TextContains $skill "luna_max_code_writer" "Skill omits the exact native role."
Assert-TextContains $skill "max reasoning" "Skill omits the pinned effort."
Assert-TextContains $skill "sole terminal bootstrap exception" "Skill omits the shell bootstrap exception."
Assert-TextContains $skill "every capability the task requests" "Skill omits the capability gate."
Assert-TextContains $skill "does not install or guarantee them" "Skill overclaims capability availability."

Assert-TextContains $interface "advanced supervisor" "Interface prompt omits the supervisor boundary."
Assert-TextContains $interface "non-Luna advanced supervisor" "Interface prompt omits the non-Luna supervisor requirement."
Assert-TextContains $interface "gpt-6-astra" "Interface prompt omits an accepted supervisor family."
Assert-TextContains $interface "gpt-5.6-sol" "Interface prompt omits an accepted supervisor family."
Assert-TextContains $interface "gpt-5.6-terra" "Interface prompt omits an accepted supervisor family."
Assert-TextContains $interface "future model" "Interface prompt omits future-model ranking."
Assert-TextContains $interface "ranked above gpt-5.6-luna" "Interface prompt omits the future-model capability comparison."
Assert-TextContains $interface "Reject Luna, unknown, and unranked identities" "Interface prompt omits rejected supervisor identities."
Assert-TextContains $interface "do not infer that every non-Luna model is advanced" "Interface prompt overclaims non-Luna models."
Assert-TextContains $interface "permissions" "Interface prompt omits permission ownership."
Assert-TextContains $interface "confirmations" "Interface prompt omits confirmation ownership."
Assert-TextContains $interface "capability" "Interface prompt omits capability checks."
Assert-TextContains $interface "does not install or guarantee" "Interface prompt overclaims capability availability."
Assert-TextContains $interface "sole terminal exception" "Interface prompt omits the shell bootstrap exception."
Assert-True ($interface -match 'allow_implicit_invocation:\s*true') "Skill interface does not allow implicit invocation."

Assert-TextContains $readme "advanced-supervisor + Luna execution plugin" "README omits the product boundary."
Assert-TextContains $readme "exposed Codex product or runtime metadata" "README omits supervisor identity preflight."
Assert-TextContains $readme "gpt-6-astra" "README omits an accepted supervisor family."
Assert-TextContains $readme "gpt-5.6-sol" "README omits an accepted supervisor family."
Assert-TextContains $readme "gpt-5.6-terra" "README omits an accepted supervisor family."
Assert-TextContains $readme "future model qualifies only" "README omits future-model ranking."
Assert-TextContains $readme "more capable than" "README omits the future-model capability comparison."
Assert-TextContains $readme "unknown identities" "README omits unknown-identity rejection."
Assert-TextContains $readme "unranked models" "README omits unranked-model rejection."
Assert-TextContains $readme "Do not infer that every non-Luna model is advanced" "README overclaims non-Luna models."
Assert-TextContains $readme "every shell or terminal command" "README omits terminal routing."
Assert-TextContains $readme "interactive browser" "README omits browser routing."
Assert-TextContains $readme "sole terminal bootstrap exception" "README omits the shell bootstrap exception."
Assert-TextContains $readme "every capability the task requests" "README omits the capability gate."
Assert-TextContains $readme "does not install or guarantee them" "README overclaims capability availability."

$routeTerms = @(
    "Every code-producing or code/config/test/build artifact mutation",
    "formatting",
    "autofix",
    "generation",
    "Every shell or terminal command",
    "build",
    "test",
    "lint",
    "typecheck",
    "diagnostics",
    "log collection",
    "process management",
    "scripted file inspection",
    "Bulk codebase exploration",
    "file search",
    "call-site discovery",
    "dependency mapping",
    "routine read-only inspection",
    "Every interactive browser action",
    "browser discovery",
    "setup",
    "recovery",
    "tab or window selection",
    "navigation",
    "visible or interactive page inspection",
    "screenshots",
    "clicks",
    "scrolling",
    "hovering",
    "keypresses or typing",
    "forms and submission",
    "dialogs",
    "uploads",
    "downloads",
    "local web testing",
    "Playwright",
    "DevTools",
    "Browser",
    "Chrome",
    "Computer Use",
    "Mechanical Windows app",
    "outside the browser",
    "Focused web or source collection",
    "routine MCP reads",
    "primary supplies the research question",
    "Bounded MCP writes and external actions",
    "exact scope",
    "assesses risk",
    "authorization",
    "user confirmation",
    "bulk extraction",
    "classification",
    "transformation",
    "structured reporting",
    "image-generation",
    "variant production",
    "primary chooses the concept",
    "accepted result"
)
foreach ($routeTerm in $routeTerms) {
    Assert-TextContains $skill $routeTerm "Skill omits routed category or boundary: $routeTerm."
    Assert-TextContains $agent $routeTerm "Agent role omits routed category or boundary: $routeTerm."
}

foreach ($agentSafetyTerm in @(
    "any requested capability is missing",
    "does not install or guarantee them",
    "sole terminal bootstrap exception",
    "After delegation",
    "narrow read-only acceptance inspection",
    "exact scope",
    "assesses risk",
    "required authorization",
    "user confirmation",
    "high-impact",
    "destructive",
    "irreversible",
    "credential-bearing",
    "financial",
    "public",
    "message-sending",
    "upload-related",
    "permission-changing",
    "Never bypass authentication",
    "required confirmation"
)) {
    Assert-TextContains $agent $agentSafetyTerm "Agent role omits safety boundary: $agentSafetyTerm."
}

$packetTerms = @(
    "DELEGATION BRIEF",
    "OUTCOME",
    "OWNED TARGETS",
    "CONSTRAINTS AND EXCLUSIONS",
    "PERMITTED TOOLS/ACTIONS",
    "SIDE-EFFECT / CONFIRMATION STATUS",
    "CHECKS / OBSERVABLE PROOF",
    "STOP CONDITIONS",
    "HANDOFF",
    "Do not omit a field",
    "BROWSER LIMITS",
    "selected/requested browser",
    "target URL/app",
    "allowed side effects",
    "confirmation state",
    "stopping condition",
    "required evidence"
)
foreach ($packetTerm in $packetTerms) {
    Assert-TextContains $skill $packetTerm "Delegation packet omits: $packetTerm."
}

foreach ($safetyTerm in @(
    "high-impact",
    "destructive",
    "irreversible",
    "credential-bearing",
    "financial",
    "public-posting",
    "message-sending",
    "upload",
    "permission-changing",
    "never bypasses authentication",
    "required confirmation",
    "same Luna worker",
    "Additional workers are allowed only for"
)) {
    Assert-TextContains $skill $safetyTerm "Safety or worker-continuity boundary is missing: $safetyTerm."
}

foreach ($staleTerm in @(
    (@("The primary model is never ", "checked") -join ""),
    (@("Do not require, ", "verify, recommend, or switch to a ", "particular primary model") -join ""),
    (@("It can be Sol, Terra, ", "Luna, or another model") -join ""),
    (@("For a request that requires neither ", "implementation code nor interactive browser control") -join "")
)) {
    Assert-TextNotContains ($readme + "`n" + $skill + "`n" + $agent + "`n" + $interface) $staleTerm "Stale primary or narrow-routing assertion remains: $staleTerm."
}

$contentFiles = @($readme, $manifestText, $agent, $skill, $interface)
$completionMarkerOne = @('TO', 'DO') -join ''
$completionMarkerTwo = @('FIX', 'ME') -join ''
$anglePattern = [string][char]60 + '[^' + [string][char]62 + '\r\n]+' + [string][char]62
foreach ($content in $contentFiles) {
    Assert-TextNotContains $content $completionMarkerOne "Unfinished marker found in an owned file."
    Assert-TextNotContains $content $completionMarkerTwo "Unfinished marker found in an owned file."
    Assert-True (-not ($content -match $anglePattern)) "Angle-bracket template syntax found in an owned file."
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$tempRoot = Join-Path $tempBase ("luna-max-coder-verify-" + [guid]::NewGuid().ToString("N"))
$target = Join-Path $tempRoot "agents"

try {
    $missingCheckFailed = $false
    try {
        & $installer -TargetDir $target -Check
    } catch {
        $missingCheckFailed = $true
    }
    Assert-True $missingCheckFailed "Check unexpectedly accepted a missing agent."
    Assert-True (-not (Test-Path -LiteralPath $target)) "Check mutated a missing target."

    & $installer -TargetDir $target
    & $installer -TargetDir $target -Check

    $installed = Join-Path $target "luna-max-code-writer.toml"
    $expectedHash = (Get-FileHash -LiteralPath $agentPath -Algorithm SHA256).Hash
    $actualHash = (Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash
    Assert-True ($expectedHash -eq $actualHash) "Installed agent differs from the template."

    & $installer -TargetDir $target
    Add-Content -LiteralPath $installed -Value "# conflict"
    $conflictHash = (Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash

    $conflictFailed = $false
    try {
        & $installer -TargetDir $target
    } catch {
        $conflictFailed = $true
    }
    Assert-True $conflictFailed "Installer overwrote or accepted a conflicting agent."
    Assert-True (((Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash) -eq $conflictHash) "Installer changed the conflicting agent."
} finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
    if ($resolvedTemp.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path -Leaf $resolvedTemp).StartsWith("luna-max-coder-verify-")) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Output "VERIFY PASSED: Luna Max Coder keeps the non-Luna primary as advanced supervisor and routes every declared execution category to GPT-5.6 Luna / Max."
