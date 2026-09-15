# Luna Max Coder

Luna Max Coder is a Windows Codex plugin that keeps supervision and operational
work in the selected advanced primary while routing only code edits and browser
actions to GPT-5.6 Luna with max reasoning. The native
`luna_max_code_writer` role accepts one exact route at a time.

## Execution boundary

The primary qualifies only when exposed Codex product or runtime metadata
identifies `gpt-6-astra`, `gpt-5.6-sol`, or `gpt-5.6-terra`. A future model
qualifies only when that metadata explicitly describes it as more capable than
`gpt-5.6-luna`. Reject Luna, unknown identities, and unranked models. Do not infer
that every non-Luna model is advanced, silently switch the primary, or add a
reviewer.

The plugin exposes two route kinds:

- `CODE_EDIT`: Luna receives exact current context and uses `apply_patch` only.
- `BROWSER_ACTION`: Luna uses only the named browser controller against the
  named browser target.

The primary performs repository discovery, file and code reads, shell and SSH,
Git, web research, MCP and data operations, non-browser Windows control,
diagnostics, linting, tests and builds. It also owns planning, permissions,
review, and acceptance. An operational task that contains no code edit or
browser action does not start Luna.

For code work, the primary supplies the exact target and patch anchors. Luna
writes the code, then the primary reviews the diff and runs all checks. For
browser work, the primary supplies the browser, target, allowed interactions,
side effects, confirmation state, and required evidence. Luna does not use
shell, source inspection, web search, MCP, or another application as a browser
fallback.

This plugin routes existing capabilities; it does not install or guarantee
them. The primary runs the non-mutating `install-agent.ps1 -Check` bootstrap.
The Luna worker never loads the routing skill or performs self-bootstrap.

High-impact, destructive, irreversible, credential-bearing, financial,
public-posting, message-sending, upload, and permission-changing actions remain
primary decisions. Luna performs only the authorized code edit or browser
action and never bypasses authentication or a required confirmation.

## Token-saving route

The primary completes discovery and planning before spawning one fresh Luna
worker with no conversation history. A code route normally needs one patch
call. A browser route uses one filtered preflight, a bounded action sequence,
and one filtered postflight. Luna returns compact artifact evidence, and the
primary performs all verification and one final review.

### Lifetime execution budget

Every delegation carries a route kind, stable route ID, and cumulative ledger.
`CODE_EDIT` allows 2 `apply_patch` calls, 2 failed calls, and 1 correction.
`BROWSER_ACTION` allows 8 browser-tool calls, 2 failed calls, and 1 correction.
Every failure counts, including path, syntax, setup, and rejected-action
errors. A disallowed tool is rejected before execution.

The ledger cannot reset on interruption, compaction, correction, handoff, or a
later turn. A bare `RESUME`, inconsistent ledger, exhausted budget, `STOP`, or
terminal handoff ends the route. Only explicit user approval in the original
delegation may raise a default.

Browser work stops after 90 seconds without observable progress. Each result is
limited to 4,000 characters, and `STOP` allows no cleanup or inspection call.

This removes Luna from operational tool loops that caused unnecessary calls. It
still does not guarantee fewer raw tokens on every task; the published runtime
measurements predate this narrower route and are retained as historical data.

## Prerequisites and limitations

You need:

- Windows with PowerShell and the Codex CLI with plugin support;
- a Codex account and a primary model whose exposed metadata satisfies the
  supervisor gate; and
- the capabilities required by your task already available to Codex.

The plugin does not provide a model, install browser or MCP access, grant
permissions, or create an operating-system security boundary. The budget is an
instruction-level contract backed by deterministic policy regression tests; it
cannot technically intercept a model or built-in tool that ignores the
contract. Use a separate process or permission boundary when adversarial hard
enforcement is required. The runtime role and installer are Windows-focused.
Python is used by CI for data-file validation, not at runtime.

## Install from a source checkout

Open PowerShell at the repository root. These commands use the supported local
marketplace and plugin commands:

~~~powershell
$repo = (Get-Location).Path
codex plugin marketplace add $repo
codex plugin add luna-max-coder@luna-max-coder

$plugin = (codex plugin list --json | ConvertFrom-Json).installed |
  Where-Object pluginId -eq "luna-max-coder@luna-max-coder"
if (-not $plugin) { throw "Luna Max Coder was not installed." }

$installer = Join-Path $plugin.source.path "scripts\install-agent.ps1"
& $installer
& $installer -Check
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
~~~

Start a new Codex conversation after installing or updating the plugin so the
skill and native role are discovered. The routing skill is explicit-only so a
Luna worker cannot activate it recursively. Activate it with:

~~~text
Use $luna-max-coder:code-routing to keep operational work in the advanced primary and route only code edits or browser actions through Luna Max.
~~~

## Upgrade and uninstall

To refresh a configured Git marketplace, run `codex plugin marketplace upgrade`.
To upgrade this source-checkout installation, run the verifier, remove the
installed plugin, and add it again:

~~~powershell
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
codex plugin remove luna-max-coder@luna-max-coder
codex plugin add luna-max-coder@luna-max-coder
$plugin = (codex plugin list --json | ConvertFrom-Json).installed |
  Where-Object pluginId -eq "luna-max-coder@luna-max-coder"
& (Join-Path $plugin.source.path "scripts\install-agent.ps1") -Update
~~~

Start a new conversation after the reinstallation. To uninstall the plugin,
run `codex plugin remove luna-max-coder@luna-max-coder`. Remove the configured
marketplace separately with `codex plugin marketplace remove luna-max-coder`
when you no longer need this source.

## Troubleshooting

- Check discovery with `codex plugin list --json`.
- Resolve the installed plugin path from that output and run
  `install-agent.ps1 -Check`. During an intentional plugin upgrade, use
  `install-agent.ps1 -Update`; it preserves the previous role as a timestamped
  backup before atomic replacement.
- Run `pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1` from
  the repository root when validation fails.
- If the primary metadata is missing, unknown, unranked, or identifies Luna,
  stop and choose a primary that satisfies the supervisor gate.
- If a task requests an unavailable capability, stop. The plugin does not
  install or guarantee capabilities.
- If a role, capability, authorization, or confirmation is unavailable, do not
  use a fallback. Resolve the boundary in the primary conversation.
- If the task contains only shell, SSH, inspection, research, MCP, data, tests,
  or non-browser application work, keep it entirely in the primary.
- Do not send `RESUME` after a stop or terminal handoff. Start a new route only
  after the user explicitly authorizes a new attempt and the primary records a
  new scope and budget.

## Validation and examples

Run the repository verifier from the root:

~~~powershell
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
~~~

See [examples/README.md](examples/README.md) for complete conversational demos
and [CHANGELOG.md](CHANGELOG.md) for version history. Report security issues
through the process in [SECURITY.md](SECURITY.md) and review the attribution in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Benchmarks

See [benchmarks/README.md](benchmarks/README.md) for historical paired token
measurements and the current routing-scope regression checks.
