# Luna Max Coder

Luna Max Coder is an advanced-supervisor + Luna execution plugin for Windows.
It is a Windows Codex plugin that separates supervision from execution. An
accepted advanced primary model remains responsible for
requirements, planning, architecture, decomposition, research synthesis, risk
and permission decisions, confirmations, review, and final acceptance.
GPT-5.6 Luna with max reasoning performs the delegated execution through the
native `luna_max_code_writer` role.

## Execution boundary

The primary qualifies only when exposed Codex product or runtime metadata
identifies `gpt-6-astra`, `gpt-5.6-sol`, or `gpt-5.6-terra`. A future model
qualifies only when that metadata explicitly describes it as more capable than
`gpt-5.6-luna`. Reject Luna, unknown identities, and unranked models. Do not infer
that every non-Luna model is advanced, silently switch the primary, or add a
reviewer.

Luna is the sole execution lane for:

- every code, configuration, test, schema, migration, build, generated,
  formatting, and autofix mutation;
- every shell or terminal command after the bootstrap exception, including
  tests, lint, type checks, diagnostics, logs, process management, and scripted
  inspection;
- bulk codebase exploration, including file search, call-site discovery,
  dependency mapping, and routine read-only inspection;
- every interactive browser action and local web test, plus mechanical Windows
  app and Computer Use actions outside the browser;
- focused web or source collection and routine MCP reads;
- bounded MCP writes and external actions after the primary defines the exact
  scope, assesses risk, and records authorization or user confirmation; and
- requested bulk extraction, classification, transformation, structured
  reporting, and image-generation execution or variant production after the
  primary chooses the concept, constraints, and accepted result.

Before task execution, verify that every capability the task requests is
available to the worker, including browser, Computer Use, MCP, web, and image
generation.
This plugin routes existing capabilities; it does not install or guarantee
them. The primary may run the provided non-mutating `install-agent.ps1 -Check`
bootstrap before Luna is available. That is the sole terminal bootstrap
exception. After delegation, every shell command routes to Luna. The primary
may perform narrow read-only acceptance inspection, but it does not resume
shell execution.

High-impact, destructive, irreversible, credential-bearing, financial,
public-posting, message-sending, upload, and permission-changing actions remain
primary decisions. Luna performs only the exact bounded action after the
normal authorization or user-confirmation boundary is established. Luna never
bypasses authentication or a required confirmation. If a role, model ranking,
requested capability, or confirmation is unavailable, routing fails closed.

## Prerequisites and limitations

You need:

- Windows with PowerShell and the Codex CLI with plugin support;
- a Codex account and a primary model whose exposed metadata satisfies the
  supervisor gate; and
- the capabilities required by your task already available to Codex.

The plugin does not provide a model, install browser or MCP access, grant
permissions, or create an operating-system security boundary. The workflow is
instruction-level enforcement. Use a separate process or permission boundary
when adversarial enforcement is required. The runtime role and installer are
Windows-focused. Python is used by CI for data-file validation, not at runtime.

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
skill and native role are discovered. Activate it with:

~~~text
Use $luna-max-coder:code-routing to supervise with the accepted advanced primary and route the requested execution through Luna Max.
~~~

## Upgrade and uninstall

To refresh a configured Git marketplace, run `codex plugin marketplace upgrade`.
To upgrade this source-checkout installation, run the verifier, remove the
installed plugin, and add it again:

~~~powershell
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
codex plugin remove luna-max-coder@luna-max-coder
codex plugin add luna-max-coder@luna-max-coder
~~~

Start a new conversation after the reinstallation. To uninstall the plugin,
run `codex plugin remove luna-max-coder@luna-max-coder`. Remove the configured
marketplace separately with `codex plugin marketplace remove luna-max-coder`
when you no longer need this source.

## Troubleshooting

- Check discovery with `codex plugin list --json`.
- Resolve the installed plugin path from that output and run
  `install-agent.ps1 -Check`. The installer refuses to overwrite a different
  role file; preserve an existing conflicting file and resolve it deliberately.
- Run `pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1` from
  the repository root when validation fails.
- If the primary metadata is missing, unknown, unranked, or identifies Luna,
  stop and choose a primary that satisfies the supervisor gate.
- If a task requests an unavailable capability, stop. The plugin does not
  install or guarantee capabilities.
- If a role, capability, authorization, or confirmation is unavailable, do not
  use a fallback. Resolve the boundary in the primary conversation.

## Validation and examples

Run the repository verifier from the root:

~~~powershell
pwsh -NoProfile -File .\plugins\luna-max-coder\scripts\verify.ps1
~~~

See [examples/README.md](examples/README.md) for complete conversational
demos. Report security issues through the process in [SECURITY.md](SECURITY.md)
and review the attribution in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Benchmarks

See [benchmarks/README.md](benchmarks/README.md) for the paired token measurements and independent behavior checks.
